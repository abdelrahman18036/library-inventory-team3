module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr_a = var.public_subnet_cidr_a
  public_subnet_cidr_b = var.public_subnet_cidr_b
  private_subnet_cidr_a = var.private_subnet_cidr_a
  private_subnet_cidr_b = var.private_subnet_cidr_b
  team_prefix = var.team_prefix
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  node_group_name = var.node_group_name
  eks_role_name = var.eks_role_name
  eks_node_role_name = var.eks_node_role_name
  eks_node_instance_type = var.eks_node_instance_type
  eks_node_min_size = var.eks_node_min_size
  eks_node_max_size = var.eks_node_max_size
  eks_node_desired_size = var.eks_node_desired_size
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  team_prefix = var.team_prefix
  eks_control_plane_sg_id = module.vpc.eks_control_plane_sg_id
}

module "ec2" {
  source = "./modules/ec2"
  manage_ec2 = var.manage_ec2
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  team_prefix = var.team_prefix
}
