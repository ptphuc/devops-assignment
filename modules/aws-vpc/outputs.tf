output "vpc_id" {
  value = aws_vpc.project.id
}

output "default_security_group" {
  value = aws_vpc.project.default_security_group_id
}

output "subnet_nat" {
  value = aws_subnet.public_nat.*.id
}

output "subnet_app" {
  value = aws_subnet.private_app.*.id
}

output "subnet_rds" {
  value = aws_subnet.private_rds.*.id
}



output "nat_gw_eips" {
  value = aws_eip.nat_gw_eip.*.public_ip
}

output "nat_instance_ips" {
  value = aws_instance.nat_instance.*.public_ip
}

output "nat_instance_eips" {
  value = aws_eip.nat_instance_eip.*.public_ip
}

