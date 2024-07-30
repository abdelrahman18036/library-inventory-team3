resource "aws_iam_role" "team3_eks_cluster" {
  name = "team3_eks_cluster_role"

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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

resource "aws_iam_role" "team3_eks_nodes" {
  name = "team3_eks_node_role"

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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

resource "aws_eks_cluster" "team3_library_cluster" {
  depends_on = [aws_iam_role.team3_eks_cluster]

  name     = "team3-library-cluster"
  role_arn = aws_iam_role.team3_eks_cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.team3_public_subnet.id, aws_subnet.team3_private_subnet.id]
    security_group_ids = [aws_security_group.team3_eks_control_plane_sg.id]
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "aws_eks_node_group" "team3_library_node_group" {
  cluster_name    = aws_eks_cluster.team3_library_cluster.name
  node_group_name = "team3-library-node-group"
  node_role_arn   = aws_iam_role.team3_eks_nodes.arn
  subnet_ids      = [aws_subnet.team3_public_subnet.id, aws_subnet.team3_private_subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_eks_cluster.team3_library_cluster,
    aws_iam_role.team3_eks_nodes
  ]
}
