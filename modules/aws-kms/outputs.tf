output "key_arn" {
  value       = join("", aws_kms_key.parameter_store.*.arn)
  description = "Key ARN"
}

output "key_id" {
  value       = join("", aws_kms_key.parameter_store.*.key_id)
  description = "Key ID"
}

output "alias_arn" {
  value       = join("", aws_kms_alias.parameter_store_alias.*.arn)
  description = "Alias ARN"
}

output "alias_name" {
  value       = join("", aws_kms_alias.parameter_store_alias.*.name)
  description = "Alias name"
}