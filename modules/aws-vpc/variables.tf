variable "name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "rds" {
  description = "Whether to create subnet group for RDS"
  default = false
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
  default = "t2.micro"
}
variable "availability_zones" {
  description = "VPC availability zones"
}

locals {
  enable_nat_ec2            = var.use_nat_instance
  enable_nat_gw             = var.use_nat_instance ? false : true
  enable_rds                = var.rds
  enable_eip_nat_instance   = var.eip_for_nat_instance
#Count AZ
  azs_count                 = length(var.availability_zones)
  azs_count_ec2             = (local.enable_nat_ec2 ? 1 : 0)  * length(var.availability_zones)
  eip_count_ec2             = (local.enable_eip_nat_instance ? 1 : 0) * local.azs_count_ec2
  azs_count_gw              = (local.enable_nat_gw ? 1 : 0) * length(var.availability_zones)
  azs_count_rds             = (local.enable_rds ? 1 : 0) * length(var.availability_zones)
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "nat_cidr_blocks" {
  description = "NAT CIDR block"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "rds_cidr_blocks" {
  description = "RDS CIDR block"
  default     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}
variable "app_cidr_blocks" {
  description = "App CIDR block"
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}


