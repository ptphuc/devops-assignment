variable "region" {
  type        = string
  description = "AWS Region the S3 bucket should reside in"
  default     = "ap-southeast-1"
}
variable "name" {
  description = "Name of project"
  type        = string
  default     = "Devops-assignment"
}
variable "environment" {
  description = "Environment type"
  type        = string
  default     = "Test"
}
variable "bucket_name" {
  description = "Name of S3 bucket to be created"
  default     = "devops-assignment-tfstates"
}

variable "policy" {
  default     = ""
  description = "Policy Json content to attach to S3 bucket"
}
variable "acl" {
  type        = string
  description = "The canned ACL to apply to the S3 bucket"
  default     = "private"
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable"
  default     = false
}

variable "block_public_acls" {
  type        = bool
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  default     = true
}

variable "ignore_public_acls" {
  type        = bool
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  default     = true
}

variable "profile" {
  type        = string
  default     = ""
  description = "AWS profile name as set in the shared credentials file"
}

variable "terraform_backend_config_file_name" {
  type        = string
  default     = "terraform.tf"
  description = "Name of terraform backend config file"
}

variable "terraform_backend_config_file_path" {
  type        = string
  default     = "./"
  description = "The path to terrafrom project directory"
}

variable "terraform_state_file" {
  type        = string
  default     = "terraform.tfstate"
  description = "The path to the state file inside the bucket"
}

variable "terraform_version" {
  type        = string
  default     = "0.12.2"
  description = "The minimum required terraform version"
}

