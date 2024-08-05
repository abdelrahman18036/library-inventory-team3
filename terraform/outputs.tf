output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id_a" {
  value = module.vpc.public_subnet_id_a
}

output "public_subnet_id_b" {
  value = module.vpc.public_subnet_id_b
}

output "private_subnet_id_a" {
  value = module.vpc.private_subnet_id_a
}

output "private_subnet_id_b" {
  value = module.vpc.private_subnet_id_b
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_node_group_name" {
  value = module.eks.node_group_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_certificate_authority_data" {
  value     = module.eks.certificate_authority_data
  sensitive = true
}

output "public_ec2_instance_id" {
  value = module.ec2.public_ec2_instance_id
}

output "public_ec2_instance_public_ip" {
  value = module.ec2.public_ec2_instance_public_ip
}

output "public_ec2_instance_public_dns" {
  value = module.ec2.public_ec2_instance_public_dns
}

output "kubeconfig" {
  value = <<EOL
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.certificate_authority_data}
  name: ${module.eks.cluster_name}
contexts:
- context:
    cluster: ${module.eks.cluster_name}
    user: ${module.eks.cluster_name}
  name: ${module.eks.cluster_name}
current-context: ${module.eks.cluster_name}
kind: Config
preferences: {}
users:
- name: ${module.eks.cluster_name}
  user:
    token: ${data.aws_eks_cluster_auth.cluster_auth.token}
EOL
  description = "Kubeconfig content"
  sensitive   = true
}
