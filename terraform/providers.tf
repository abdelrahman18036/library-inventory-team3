provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.library_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.library_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.library_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  # config_path            = "~/.kube/config"
  # config_context         = "arn:aws:eks:us-west-2:637423483309:cluster/team3-library-cluster"
}
