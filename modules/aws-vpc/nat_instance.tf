resource "aws_eip" "nat_instance_eip" {
  count = local.eip_count_ec2
  tags = {
    Name = "${var.name}.nat.instance.eip.${count.index}"
  }
}

data "aws_ami" "nat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "nat_instance" {
  count                       = local.azs_count_ec2
  ami                         = data.aws_ami.nat.id
  instance_type               = var.nat_instance_type
  source_dest_check           = false
  subnet_id                   = element(aws_subnet.public_nat.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.access_via_nat[0].id]

  tags = {
    Name = "${var.name}.nat.${count.index}"
  }

  lifecycle {
    # Ignore changes to the NAT AMI data source.
    ignore_changes = [ami]
  }

  volume_tags = {
    Name        = "${var.name}-${format("private-%03d NAT", count.index)}"
    Environment = var.environment
  }
}

resource "aws_eip_association" "nat_instance_eip_attach" {
  # Create these only if using NAT instances, vs. the NAT gateway service.
  count         = local.eip_count_ec2
  instance_id   = element(aws_instance.nat_instance.*.id, count.index)
  allocation_id = element(aws_eip.nat_instance_eip.*.id, count.index)
}

resource "aws_route_table" "nat_instance_rt" {
  count = local.azs_count_ec2

  vpc_id = aws_vpc.project.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = element(aws_instance.nat_instance.*.id, count.index)
  }

  tags = {
    Name = "${var.name}.rt.nat.${count.index}-wan"
  }
}

resource "aws_route_table_association" "app_subnet_to_nat_instance" {
  count = local.azs_count_ec2

  route_table_id = element(aws_route_table.nat_instance_rt.*.id, count.index)
  subnet_id      = element(aws_subnet.private_app.*.id, count.index)
}

