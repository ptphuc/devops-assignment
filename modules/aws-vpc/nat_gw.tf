# Create EIP for NAT_GW depend on choice
resource "aws_eip" "nat_gw_eip" {
  count = local.azs_count_gw

  tags = {
    Name = "${var.name}.nat.gw.eip.${count.index}"
  }
}


resource "aws_nat_gateway" "nat_gw" {
  count         = local.azs_count_gw
  allocation_id = element(aws_eip.nat_gw_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_nat.*.id, count.index)

  tags = {
    Name = "${var.name}.nat.gw.${count.index}"
  }
}

resource "aws_route_table" "nat_gw" {
  count  = local.azs_count_gw
  vpc_id = aws_vpc.project.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }

  tags = {
    Name = "${var.name}.rt.nat.${count.index}-wan"
  }
}

resource "aws_route_table_association" "app_subnet_to_nat_gw" {
  count          = local.azs_count_gw
  route_table_id = element(aws_route_table.nat_gw.*.id, count.index)
  subnet_id      = element(aws_subnet.private_app.*.id, count.index)
}

