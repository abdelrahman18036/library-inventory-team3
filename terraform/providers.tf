provider "aws" {
  region  = "us-west-2"
  profile = "orange-team3"
}

data "aws_eks_cluster_auth" "team3_library_cluster" {
  name = aws_eks_cluster.team3_library_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.team3_library_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.team3_library_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.team3_library_cluster.token
}
