variable "manage_ec2" {
  description = "Set to false to prevent managing the EC2 instance"
  type        = bool
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "team_prefix" {
  description = "Prefix for naming resources"
  type        = string
}
