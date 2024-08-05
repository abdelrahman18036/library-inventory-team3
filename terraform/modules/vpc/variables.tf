variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr_a" {
  description = "The CIDR block for the public subnet A."
  type        = string
}

variable "public_subnet_cidr_b" {
  description = "The CIDR block for the public subnet B."
  type        = string
}

variable "private_subnet_cidr_a" {
  description = "The CIDR block for the private subnet A."
  type        = string
}

variable "private_subnet_cidr_b" {
  description = "The CIDR block for the private subnet B."
  type        = string
}

variable "team_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
