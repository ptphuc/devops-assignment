provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 0.12.2"
  backend "s3" {
    region         = "ap-southeast-1"
    bucket         = "devops-assignment-tfstates"
    key            = "terraform.tfstate"
  }
}


