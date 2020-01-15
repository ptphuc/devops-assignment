terraform {
  required_version = ">= ${terraform_version}"

  backend "s3" {
    region         = "${region}"
    bucket         = "${bucket}"
    key            = "${terraform_state_file}"
  }
}
