output "cluster_endpoint" {
  value = aws_eks_cluster.library_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.library_cluster.name
}

output "node_group_name" {
  value = aws_eks_node_group.library_node_group.node_group_name
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
