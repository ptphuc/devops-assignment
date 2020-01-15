locals {
  instance_count       = var.instance_enabled ? 1 : 0
  security_group_count = var.create_default_security_group ? 1 : 0
  region               = var.region != "" ? var.region : data.aws_region.default.name
  availability_zone    = var.availability_zone != "" ? var.availability_zone : data.aws_subnet.default.availability_zone
  ami                  = var.ami != "" ? var.ami : data.aws_ami.default.image_id
  ami_owner            = var.ami != "" ? var.ami_owner : data.aws_ami.default.owner_id
  root_volume_type     = var.root_volume_type != "" ? var.root_volume_type : data.aws_ami.info.root_device_type
  public_dns           = var.associate_public_ip_address && var.assign_eip_address && var.instance_enabled ? data.null_data_source.eip.outputs["public_dns"] : join("", aws_instance.default.*.public_dns)
}

data "aws_caller_identity" "default" {
}

data "aws_region" "default" {
}

data "aws_subnet" "default" {
  id = var.subnet
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_ami" "default" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "aws_ami" "info" {
  filter {
    name   = "image-id"
    values = [local.ami]
  }

  owners = [local.ami_owner]
}
# Policy Document to allow KMS Decryption with given keys
data "aws_iam_policy_document" "kms_permissions" {
  count = var.kms_decrypt ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = var.kms_keys
  }
}
data "aws_iam_policy_document" "ssm_permissions" {
  count = var.kms_decrypt && var.ssm_access ? 1 : 0

  ## Add Describe Parameters as per https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
  statement {
    effect    = "Allow"
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }
  ## With the custom application prefix for ssm
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "ssm:GetParametersByPath", "ssm:GetParameters"]
    resources = formatlist("arn:aws:ssm:${var.region}:${data.aws_caller_identity.default.account_id}:parameter/application/%s/*",var.ssm_paths)
  }

  ## And also without the application prefix
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "ssm:GetParametersByPath", "ssm:GetParameters"]
    resources = formatlist("arn:aws:ssm:${var.region}:${data.aws_caller_identity.default.account_id}:parameter/%s/*",var.ssm_paths)
  }
}
resource "aws_iam_role" "default" {
  count              = local.instance_count
  name               = "${var.name}-${var.environment}-ec2-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.default.json
}
resource "aws_iam_role_policy" "kms_permissions" {
  count  = var.kms_decrypt ? 1 : 0
  name   = "${var.name}-${var.environment}-ec2-kms-permissions"
  role   = aws_iam_role.default[0].id
  policy = data.aws_iam_policy_document.kms_permissions[0].json
}
resource "aws_iam_role_policy" "ssm_permissions" {
  count = var.ssm_access ? 1 : 0
  name  = "${var.name}-${var.environment}-ec2-ssm-permissions"
  role = aws_iam_role.default[0].id
  policy = data.aws_iam_policy_document.ssm_permissions[0].json
}

resource "aws_iam_instance_profile" "default" {
  count = local.instance_count
  name  = "${var.name}-${var.environment}-ec2-instance-profile"
  role  = join("", aws_iam_role.default.*.name)
}

resource "aws_instance" "default" {
  count                       = local.instance_count
  ami                         = local.ami
  availability_zone           = local.availability_zone
  instance_type               = var.instance_type
  user_data                   = var.user_data
  iam_instance_profile        = join("", aws_iam_instance_profile.default.*.name)
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.ssh_key_pair
  subnet_id                   = var.subnet
  source_dest_check           = var.source_dest_check
  vpc_security_group_ids = compact(
  concat(
  [
    var.create_default_security_group ? join("", aws_security_group.default.*.id) : "",
  ],
  var.security_groups
  )
  )

  root_block_device {
    volume_type           = local.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.delete_on_termination
  }

  tags = {
    Name          = "${var.name}-${var.environment}-ec2"
    Environment   = var.environment
  }
}

resource "aws_eip" "default" {
  count             = var.associate_public_ip_address && var.assign_eip_address && var.instance_enabled ? 1 : 0
  network_interface = join("", aws_instance.default.*.primary_network_interface_id)
  vpc               = true
  tags = {
    Name          = "${var.name}-${var.environment}-EC2-EIP"
    Environment   = var.environment
  }
}
data "null_data_source" "eip" {
  inputs = {
    public_dns = "ec2-${replace(join("", aws_eip.default.*.public_ip), ".", "-")}.${local.region == "us-east-1" ? "compute-1" : "${local.region}.compute"}.amazonaws.com"
  }
}