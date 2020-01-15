locals {
  terraform_backend_config_file = format(
    "%s/%s",
    var.terraform_backend_config_file_path,
    var.terraform_backend_config_file_name
  )
}

resource "aws_s3_bucket" "default" {
  bucket        = var.bucket_name
  acl           = var.acl
  region        = var.region
  force_destroy = var.force_destroy
  policy        = var.policy

  versioning {
    enabled = true
  }
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}


resource "aws_s3_bucket_public_access_block" "default" {
  bucket                  = aws_s3_bucket.default.id
  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  block_public_policy     = var.block_public_policy
  restrict_public_buckets = var.restrict_public_buckets
}

data "template_file" "terraform_backend_config" {
  template = file("${path.module}/templates/terraform.tf.tpl")

  vars = {
    region               = var.region
    bucket               = aws_s3_bucket.default.id
    terraform_version    = var.terraform_version
    terraform_state_file = var.terraform_state_file
  }
}

resource "local_file" "terraform_backend_config" {
  count    = var.terraform_backend_config_file_path != "" ? 1 : 0
  content  = data.template_file.terraform_backend_config.rendered
  filename = local.terraform_backend_config_file
}