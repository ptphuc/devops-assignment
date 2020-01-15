

resource "aws_db_instance" "default" {
  count                 = var.enabled ? 1 : 0
  identifier            = "${var.engine}-rds"
  name                  = var.database_name
  username              = var.database_user
  password              = var.database_password
  port                  = var.database_port
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_arn

  vpc_security_group_ids = compact(
  concat(
  [join("", aws_security_group.default.*.id)],
  var.associate_security_group_ids
  )
  )

  db_subnet_group_name        = join("", aws_db_subnet_group.default.*.name)
  parameter_group_name        = length(var.parameter_group_name) > 0 ? var.parameter_group_name : join("", aws_db_parameter_group.default.*.name)
  option_group_name           = length(var.option_group_name) > 0 ? var.option_group_name : join("", aws_db_option_group.default.*.name)
  license_model               = var.license_model
  multi_az                    = var.multi_az
  storage_type                = var.storage_type
  iops                        = var.iops
  publicly_accessible         = var.publicly_accessible
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  deletion_protection         = var.deletion_protection

  tags = {
    Name                = "${var.name}.${var.engine_version}.RDS"
    Environment         = var.environment
  }
}

resource "aws_db_parameter_group" "default" {
  count  = length(var.parameter_group_name) == 0 && var.enabled ? 1 : 0
  name   = "${var.name}-${var.engine}-grp"
  family = var.db_parameter_group
  tags   = {
    Name        = "${var.engine}.${var.engine_version}.parameter.grp"
    Environment = var.environment
  }

  dynamic "parameter" {
    for_each = var.db_parameter
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

resource "aws_db_option_group" "default" {
  count                = length(var.option_group_name) == 0 && var.enabled ? 1 : 0
  name                 = "${var.name}-${var.engine}-option-grp"
  engine_name          = var.engine
  major_engine_version = local.major_engine_version
  tags   = {
    Name        = "${var.engine}.${var.engine_version}.db.option.grp"
    Environment = var.environment
  }

  dynamic "option" {
    for_each = var.db_options
    content {
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "default" {
  count      = var.enabled ? 1 : 0
  name       = "${var.name}.sn.grp"
  subnet_ids = var.subnet_ids
  tags       = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_security_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name}.${var.engine_version}.rds.sg"
  description = "Allow inbound traffic from the security groups"
  vpc_id      = var.vpc_id
  tags        = {
    Name        = "${var.name}-${var.engine}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled ? 1 : 0
  #count                    = var.enabled ? length(var.security_group_ids) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  source_security_group_id = var.security_group_ids[0]
  security_group_id        = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = var.database_port
  to_port           = var.database_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}