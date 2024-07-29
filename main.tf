provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main_new" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_new" {
  count                   = 2
  vpc_id                  = aws_vpc.main_new.id
  cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

data "aws_availability_zones" "available" {}

resource "aws_iam_role" "eks_role_new" {
  name = "eks-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "eks-policy-new"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "eks:*"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_eks_cluster" "example_new" {
  name     = "library-inventory-team4"
  role_arn = aws_iam_role.eks_role_new.arn

  vpc_config {
    subnet_ids = aws_subnet.example_new[*].id
  }
}

resource "aws_iam_role" "node_role_new" {
  name = "node-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "node-policy-new"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "ec2:*"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_eks_node_group" "example_new" {
  cluster_name    = aws_eks_cluster.example_new.name
  node_group_name = "library-inventory-team4-group"
  node_role_arn   = aws_iam_role.node_role_new.arn
  subnet_ids      = aws_subnet.example_new[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}

data "aws_eks_cluster_auth" "example_new" {
  name = aws_eks_cluster.example_new.name
}

output "kubeconfig" {
  sensitive = true
  value = <<EOL
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.example_new.endpoint}
      certificate-authority-data: ${aws_eks_cluster.example_new.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    token: ${data.aws_eks_cluster_auth.example_new.token}
EOL
}
