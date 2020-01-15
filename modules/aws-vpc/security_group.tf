resource "aws_security_group" "access_via_nat" {
  count = local.enable_nat_ec2 ? 1 : 0

  vpc_id = aws_vpc.project.id

  name        = "${var.name}.sg"
  description = "Private nodes to internet"

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}.nat.instance.sg"
  }
}

resource "aws_security_group_rule" "allow_inbound_traffic" {
  count = local.azs_count_ec2

  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "all"

  cidr_blocks       = [element(aws_subnet.private_app.*.cidr_block, count.index)]
  security_group_id = aws_security_group.access_via_nat[0].id
}