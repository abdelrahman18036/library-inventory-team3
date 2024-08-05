output "vpc_id" {
  value = aws_vpc.team_vpc.id
}

output "public_subnet_id_a" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_id_b" {
  value = aws_subnet.public_subnet_b.id
}

output "private_subnet_id_a" {
  value = aws_subnet.private_subnet_a.id
}

output "private_subnet_id_b" {
  value = aws_subnet.private_subnet_b.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}
