resource "aws_kms_key" "parameter_store" {
    description             = var.description
    is_enabled              = var.is_enabled
    deletion_window_in_days = var.deletion_window_in_days
    enable_key_rotation     = var.enable_key_rotation
    policy                  = var.policy

    tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_kms_alias" "parameter_store_alias" {
  name          = "alias/${var.kms_alias_name}"
  target_key_id = aws_kms_key.parameter_store.id
}