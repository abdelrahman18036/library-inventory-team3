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
}

output "kubernetes_host" {
  value = aws_eks_cluster.library_cluster.endpoint
}

output "kubernetes_cluster_ca_certificate" {
  value = aws_eks_cluster.library_cluster.certificate_authority[0].data
}

output "kubernetes_token" {
  value = data.aws_eks_cluster_auth.cluster_auth.token
}

output "cluster_name" {
  value = aws_eks_cluster.library_cluster.name
}
