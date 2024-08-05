variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group."
  type        = string
}

variable "eks_role_name" {
  description = "The name of the EKS role."
  type        = string
}

variable "eks_node_role_name" {
  description = "The name of the EKS node role."
  type        = string
}

variable "eks_node_instance_type" {
  description = "The instance type for EKS nodes."
  type        = string
}

variable "eks_node_min_size" {
  description = "The minimum size of the EKS node group."
  type        = number
}

variable "eks_node_max_size" {
  description = "The maximum size of the EKS node group."
  type        = number
}

variable "eks_node_desired_size" {
  description = "The desired size of the EKS node group."
  type        = number
}

variable "public_subnet_ids" {
  description = "Public subnet IDs."
  type        = list(string)
}

variable "eks_control_plane_sg_id" {
  description = "Security group ID for EKS control plane."
  type        = string
}

variable "team_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster is created."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster."
  type        = list(string)
}
