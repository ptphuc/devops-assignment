# allow internet access to nat
resource "aws_route_table" "public_to_internet" {
  count  = local.azs_count
  vpc_id = aws_vpc.project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.name}.gw.nat.${count.index}-wan"
  }
}

resource "aws_route_table_association" "internet_for_public" {
  count          = local.azs_count
  route_table_id = element(aws_route_table.public_to_internet.*.id, count.index)
  subnet_id      = element(aws_subnet.public_nat.*.id, count.index)
}

