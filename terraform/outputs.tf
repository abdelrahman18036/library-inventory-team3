output "kubeconfig" {
  value = <<EOL
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.library_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.library_cluster.certificate_authority[0].data}
  name: ${aws_eks_cluster.library_cluster.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.library_cluster.name}
    user: ${aws_eks_cluster.library_cluster.name}
  name: ${aws_eks_cluster.library_cluster.name}
current-context: ${aws_eks_cluster.library_cluster.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.library_cluster.name}
  user:
    token: ${data.aws_eks_cluster_auth.cluster_auth.token}
EOL
  description = "Kubeconfig content"
}

output "certificate_authority_data" {
  value = aws_eks_cluster.library_cluster.certificate_authority[0].data
}

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
