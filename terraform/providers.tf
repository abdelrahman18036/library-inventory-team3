# Configure the AWS provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Data source to get available AWS availability zones
data "aws_availability_zones" "available" {}

# Data source to authenticate with EKS cluster
data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

# Configure the Kubernetes provider to interact with the EKS cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}
