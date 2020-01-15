module "vpc" {
  source               = "./modules/aws-vpc"
  region               = var.region
  name                 = var.name
  environment          = var.environment
  vpc_cidr_block       = var.vpc_cidr_block
  nat_cidr_blocks      = var.nat_cidr_blocks
  rds_cidr_blocks      = var.rds_cidr_blocks
  app_cidr_blocks      = var.app_cidr_blocks
  rds                  = var.rds
  eip_for_nat_instance = var.eip_for_nat_instance
  use_nat_instance     = var.use_nat_instance
  nat_instance_type    = var.nat_instance_type
  availability_zones   = var.availability_zones
}

module "kms" {
  source                  = "./modules/aws-kms"
  name                    = var.name
  environment             = var.environment
  region                  = var.region
  is_enabled              = var.is_enabled
  description             = var.description
  kms_alias_name          = var.kms_alias_name
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = var.policy
}


resource "random_password" "db_password" {
  length  = 16
  special = false
}


resource "aws_ssm_parameter" "secret" {
  name        = "/${var.name}/database/password/master"
  description = "Database Password"
  type        = "SecureString"
  value       = random_password.db_password.result
  key_id      = module.kms.key_arn
  overwrite   = true

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

module "ec2-keypair" {
  source              = "./modules/aws-keypair"
  key_name            = var.key_name
  generate_ssh_key    = true
  ssh_public_key_path = "./key-pair"
}
module "ec2_instance" {
  source           = "./modules/aws-ec2"
  name             = var.name
  environment      = var.environment
  region           = var.region
  ssh_key_pair     = module.ec2-keypair.key_name
  subnet           = module.vpc.subnet_nat[0]
  vpc_id           = module.vpc.vpc_id
  ssm_access       = true
  ssm_paths        = [var.name]
  kms_decrypt      = true
  kms_keys         = [module.kms.key_arn]
  root_volume_size = 16
  allowed_ports    = [80, 22, 8000] #Port 8000 for Django app Testing Purpose

}

module "postgresl-rds" {
  source              = "./modules/aws-rds"
  name                = var.name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.subnet_rds
  security_group_ids  = module.ec2_instance.security_group_ids
  publicly_accessible = var.publicly_accessible
  database_name       = var.database_name
  database_user       = var.database_user
  database_password   = random_password.db_password.result
  database_port       = var.database_port
  multi_az            = var.multi_az
  storage_type        = var.storage_type
  allocated_storage   = var.allocated_storage
  storage_encrypted   = var.storage_encrypted
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  db_parameter_group  = var.db_parameter_group
  apply_immediately   = var.apply_immediately
  deletion_protection = var.deletion_protection
}
# Generate app_config file used for apply ansible configuration for deploying App
locals {
  app_config_file = format(
    "%s/%s",
    var.app_config_file_path,
    var.app_config_file_name
  )
}
data "template_file" "app_config" {
  template = file("${path.module}/templates/app_config.yml.tpl")

  vars = {
    instance_public_ip = module.ec2_instance.public_ip
    db_name            = var.database_name
    db_user            = var.database_user
    db_password        = random_password.db_password.result
    db_port            = var.database_port
    db_host            = module.postgresl-rds.instance_address
  }
}
resource "local_file" "app_config" {
  count    = var.app_config_file_path != "" ? 1 : 0
  content  = data.template_file.app_config.rendered
  filename = local.app_config_file
}

# This is to call local exec and run ansible command.
resource "null_resource" "provisioner" {
  depends_on = [module.postgresl-rds, module.ec2_instance]
  triggers = {
    instance_public_ip = module.ec2_instance.public_ip
  }
  provisioner "local-exec" {
    command = "ansible-playbook --private-key ${module.ec2-keypair.private_key_filename} ./ansible/ec2-instance.yml"
  }
}