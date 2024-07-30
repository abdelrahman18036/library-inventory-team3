variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "The AWS profile to use."
  type        = string
  default     = "orange"
}

variable "team_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "team3"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "team3-library-cluster"
}

variable "node_group_name" {
  description = "The name of the EKS node group."
  type        = string
  default     = "team3-library-node-group"
}

variable "eks_role_name" {
  description = "The name of the EKS role."
  type        = string
  default     = "team3_eks_cluster_role"
}

variable "eks_node_role_name" {
  description = "The name of the EKS node role."
  type        = string
  default     = "team3_eks_node_role"
}

variable "eks_node_instance_type" {
  description = "The instance type for EKS nodes."
  type        = string
  default     = "t3.medium"
}

variable "eks_node_min_size" {
  description = "The minimum size of the EKS node group."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "The maximum size of the EKS node group."
  type        = number
  default     = 2
}

variable "eks_node_desired_size" {
  description = "The desired size of the EKS node group."
  type        = number
  default     = 1
}
