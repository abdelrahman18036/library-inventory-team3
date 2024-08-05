output "vpc_id" {
  value = aws_vpc.team_vpc.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "eks_control_plane_sg_id" {
  value = aws_security_group.eks_control_plane_sg.id
}
