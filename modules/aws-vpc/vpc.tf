
# Create VPC
resource "aws_vpc" "project" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = {
    Name        = "${var.name}.vpc"
    Environment = var.environment
  }
}

#Create Internet Gateway for VPC
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.project.id
  tags = {
    Name        = "${var.name}.IGW"
    Environment = var.environment
  }
}

#Subnets

