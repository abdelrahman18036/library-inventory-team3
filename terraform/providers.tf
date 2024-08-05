provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  host                   = module.eks.kubernetes_host
  cluster_ca_certificate = module.eks.kubernetes_cluster_ca_certificate
  token                  = module.eks.kubernetes_token
  config_path            = "C:\\Users\\abdel\\.kube\\config"
  config_context         = "arn:aws:eks:us-west-2:637423483309:cluster/team3-library-cluster"
}
