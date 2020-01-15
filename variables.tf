#AWS
variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}
#Project
variable "name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

#AWS Vpc
variable "vpc_cidr_block" {
  description = "VPC CIDR block"
}
variable "nat_cidr_blocks" {
  description = "NAT CIDR block"
}
variable "rds_cidr_blocks" {
  description = "RDS CIDR block"
}
variable "app_cidr_blocks" {
  description = "App CIDR block"
}
variable "rds" {
  description = "Whether to create subnet group for RDS"
}
variable "eip_for_nat_instance" {
  description = "Whether to attach EIP to Nat Instances"
  default     = false
}
variable "use_nat_instance" {
  description = "Enable NAT Instance"
  default     = true
}
variable "nat_instance_type" {
  description = "EC2 Instance type used as Nat instance. i.e t2.micro,t3.nano"
}
variable "availability_zones" {
  description = "VPC availability zones"
}

#AWS KMS
variable "is_enabled" {
  description = "Specifies whether the key is enabled."
  default     = true
}

variable "description" {
  description = "The description of the key as viewed in AWS console."
}

variable "policy" {
  description = "A valid policy JSON document. For more information about building AWS IAM policy documents with Terraform."
  default     = ""
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  default     = "30"
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled."
  default     = false
}

variable "kms_alias_name" {
  description = "This variable use to create kms/alias key for AWS SSM as format alias/{kms_alias_name}"
}


# AWS RDS argument
variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "The IDs of the security groups from which to allow `ingress` traffic to the DB instance"
}
variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "The whitelisted CIDRs which to allow `ingress` traffic to the DB instance"
}
variable "database_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
}

variable "database_user" {
  type        = string
  default     = ""
  description = "(Required unless a `snapshot_identifier` or `replicate_source_db` is provided) Username for the master DB user"
}

variable "database_password" {
  type        = string
  default     = ""
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user"
}

variable "database_port" {
  type        = number
  description = "Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`"
}

variable "deletion_protection" {
  type        = bool
  description = "Set to true to enable deletion protection on the RDS instance"
  default     = false
}

variable "multi_az" {
  type        = bool
  description = "Set to true if multi AZ deployment must be supported"
  default     = false
}

variable "storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
}

variable "storage_encrypted" {
  type        = bool
  description = "(Optional) Specifies whether the DB instance is encrypted. The default is false if not specified"
  default     = false
}


variable "allocated_storage" {
  type        = number
  description = "The allocated storage in GBs"
}

variable "engine" {
  type        = string
  description = "Database engine type"
  # - mysql
  # - postgres
  # - oracle-*
  # - sqlserver-*
}
variable "engine_version" {
  type        = string
  description = "Database engine version, depends on engine type"
}

variable "instance_class" {
  type        = string
  description = "Class of RDS instance"
}

variable "publicly_accessible" {
  type        = bool
  description = "Determines if database can be publicly available (NOT recommended)"
  default     = true
}

//variable "vpc_id" {
//  type        = string
//  description = "VPC ID the DB instance will be created in"
//}


variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = true
}

variable "db_parameter_group" {
  type        = string
  description = "Parameter group, depends on DB engine used"
  # "mysql5.6"
  # "postgres9.5"
}

#AWS Keypair
variable "key_name" {
  description = "Name of keypair created on AWS console"
  type        = string
}

variable "app_config_file_path" {
  description = "Path to store the app_config.yml"
  type        = string
  default     = "./ansible/var/"
}
variable "app_config_file_name" {
  type        = string
  default     = "app_config.yml"
  description = "Name of app backend config file"
}


