module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr_a = var.public_subnet_cidr_a
  public_subnet_cidr_b = var.public_subnet_cidr_b
  private_subnet_cidr_a = var.private_subnet_cidr_a
  private_subnet_cidr_b = var.private_subnet_cidr_b
  team_prefix          = var.team_prefix
  cluster_name         = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  team_prefix               = var.team_prefix
  cluster_name              = var.cluster_name
  node_group_name           = var.node_group_name
  subnet_ids                = [module.vpc.public_subnet_id_a, module.vpc.public_subnet_id_b, module.vpc.private_subnet_id_a, module.vpc.private_subnet_id_b]
  eks_control_plane_sg_id   = aws_security_group.eks_control_plane_sg.id
  eks_node_desired_size     = var.eks_node_desired_size
  eks_node_min_size         = var.eks_node_min_size
  eks_node_max_size         = var.eks_node_max_size
}

module "ec2" {
  source = "./modules/ec2"

  team_prefix      = var.team_prefix
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_id_a
  key_name         = var.key_name
  volume_size      = 20
  user_data        = <<EOF
    #!/bin/bash
    # Your user data script here
  EOF
  manage_ec2       = var.manage_ec2
}
