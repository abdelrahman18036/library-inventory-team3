output "cluster_name" {
  value = aws_eks_cluster.library_cluster.name
}

output "node_group_name" {
  value = aws_eks_node_group.library_node_group.node_group_name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.library_cluster.endpoint
}

output "certificate_authority_data" {
  value = aws_eks_cluster.library_cluster.certificate_authority[0].data
  sensitive = true
}
