variable "key_name" {
  type = string
  description = "Name of key pair"
}
variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key directory (e.g. `/secrets`)"
}

variable "generate_ssh_key" {
  type        = bool
  default     = false
  description = "If set to `true`, new SSH key pair will be created"
}

variable "ssh_key_algorithm" {
  type        = string
  default     = "RSA"
  description = "SSH key algorithm"
}

variable "private_key_extension" {
  type        = string
  default     = ""
  description = "Private key extension"
}

variable "public_key_extension" {
  type        = string
  default     = ".pub"
  description = "Public key extension"
}

variable "chmod_command" {
  type        = string
  default     = "chmod 600 %v"
  description = "Template of the command executed on the private key file"
}