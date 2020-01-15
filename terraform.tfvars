region                = "ap-southeast-1"
name                  = "devops"
environment           = "test"

#VPC
vpc_cidr_block        = "10.0.0.0/16"
nat_cidr_blocks       = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
rds_cidr_blocks       = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
app_cidr_blocks       = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
rds                   = true
eip_for_nat_instance  = false
use_nat_instance      = true
nat_instance_type     = "t2.micro"

availability_zones    = ["ap-southeast-1a", "ap-southeast-1b"]

#KMS
is_enabled            = true
description           = "Parameter store kms master key"
kms_alias_name        = "parameter_store_key"

#RDS
publicly_accessible   = true
instance_class        = "db.t2.micro"
engine                = "postgres"
engine_version        = "10.5"
db_parameter_group    = "postgres10"
database_name         = "devops"
database_user         = "devops"
database_port         = "5432"
allocated_storage     = 20
storage_encrypted     = false
storage_type          = "standard"
multi_az              = false
deletion_protection   = false
apply_immediately     = true

#AWS Key pair
key_name              = "devops-ec2"