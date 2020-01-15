resource "aws_subnet" "public_nat" {
  count             = local.azs_count
  cidr_block        = var.nat_cidr_blocks[count.index]
  vpc_id            = aws_vpc.project.id
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name       = "${var.name}.sn.nat.${count.index}"
    Visibility = "Public"
  }
}

resource "aws_subnet" "private_rds" {
  count = local.azs_count_rds

  vpc_id            = aws_vpc.project.id
  cidr_block        = var.rds_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name       = "${var.name}.sn.rds.${count.index}"
    Visibility = "Private"
  }
}
resource "aws_subnet" "private_app" {
  count = local.azs_count

  vpc_id            = aws_vpc.project.id
  cidr_block        = var.app_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name       = "${var.name}.sn.app.${count.index}"
    Visibility = "Private"
  }
}