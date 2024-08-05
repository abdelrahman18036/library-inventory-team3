variable "team_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair"
  type        = string
}

variable "volume_size" {
  description = "The size of the root volume"
  type        = number
}

variable "user_data" {
  description = "The user data script"
  type        = string
  default     = ""
}

variable "manage_ec2" {
  description = "Set to false to prevent managing the EC2 instance"
  default     = true
}
