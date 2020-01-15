variable "name" {
  description = "Name of project"
  type        = string
}
variable "environment" {
  description = "Environment type"
  type        = string
}

#AWS provider

variable "region" {
  description = "the AWS region in which resources are created."
}

#KMS
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
  description = "This variable use to create kms/alias key for AWS SSM"
}