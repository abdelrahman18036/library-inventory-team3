provider "aws" {
  region = "us-west-2"  # Change to your preferred region
}

# EKS Cluster
resource "aws_eks_cluster" "example" {
  name     = "library-inventory-cluster"
  role_arn  = aws_iam_role.eks_cluster.arn
  version   = "1.21"  # Update to your desired Kubernetes version

  vpc_config {
    subnet_ids = aws_subnet.example[*].id
  }

  tags = {
    Name = "library-inventory-cluster"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for EKS Node Group
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# EKS Node Group
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "library-inventory-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.example[*].id
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Update your AMI type if necessary
  ami_type = "AL2_x86_64"

  tags = {
    Name = "library-inventory-node-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "example" {
  count = 2

  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}

# Security Group
resource "aws_security_group" "example" {
  vpc_id = aws_vpc.example.id
}

# Output for EKS Cluster
output "cluster_name" {
  value = aws_eks_cluster.example.name
}

# Output for EKS Node Group
output "node_group_name" {
  value = aws_eks_node_group.example.node_group_name
}
