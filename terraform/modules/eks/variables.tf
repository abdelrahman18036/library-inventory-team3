variable "team_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "eks_control_plane_sg_id" {
  description = "Security group ID for EKS control plane"
  type        = string
}

variable "eks_node_desired_size" {
  description = "The desired size of the EKS node group."
  type        = number
}

variable "eks_node_min_size" {
  description = "The minimum size of the EKS node group."
  type        = number
}

variable "eks_node_max_size" {
  description = "The maximum size of the EKS node group."
  type        = number
}
