# Output for Kubernetes Config (kubeconfig)
output "kubeconfig" {
  value = <<EOL
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.kubernetes_host}
    certificate-authority-data: ${module.eks.kubernetes_cluster_ca_certificate}
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
    token: ${module.eks.kubernetes_token}
EOL
  description = "The Kubernetes configuration file content."
  sensitive   = true
}

# Output for VPC ID
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the created VPC."
}

# Output for Public Subnet IDs
output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "The IDs of the public subnets created in the VPC."
}

# Output for Private Subnet IDs
output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "The IDs of the private subnets created in the VPC."
}

# Output for EKS Cluster Name
output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster."
}

# Output for Kubernetes API Server Endpoint
output "kubernetes_host" {
  value       = module.eks.kubernetes_host
  description = "The Kubernetes API server endpoint."
}

# Output for Kubernetes Cluster CA Certificate
output "kubernetes_cluster_ca_certificate" {
  value       = module.eks.kubernetes_cluster_ca_certificate
  description = "The Kubernetes cluster CA certificate."
}

# Output for Kubernetes Authentication Token
output "kubernetes_token" {
  value       = module.eks.kubernetes_token
  description = "The Kubernetes authentication token."
  sensitive   = true
}

# Output for Public EC2 Instance ID
output "public_ec2_instance_id" {
  value       = module.ec2.public_ec2_instance_id
  description = "The ID of the public EC2 instance."
}

# Output for Public EC2 Instance Public IP
output "public_ec2_instance_public_ip" {
  value       = module.ec2.public_ec2_instance_public_ip
  description = "The public IP address of the public EC2 instance."
}

# Output for Public EC2 Instance Public DNS
output "public_ec2_instance_public_dns" {
  value       = module.ec2.public_ec2_instance_public_dns
  description = "The public DNS of the public EC2 instance."
}
