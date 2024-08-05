resource "aws_security_group" "public_ec2_sg" {
  name        = "${var.team_prefix}_public_ec2_sg"
  description = "Security group for the public EC2 instance"
  vpc_id      = var.vpc_id

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP address in CIDR notation for better security
  }

  # Allow HTTP access on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows traffic from any IP. Consider restricting it if necessary.
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.team_prefix}_public_ec2_sg"
  }
}

resource "aws_instance" "public_ec2" {
  count = var.manage_ec2 ? 1 : 0
  ami                    = "ami-0aff18ec83b712f05"
  instance_type          = "t3.medium"
  key_name               = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size
  }

  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
  subnet_id              = var.subnet_id

  tags = {
    Name        = "${var.team_prefix}_public_ec2"
    Environment = "protected"
  }

  user_data = var.user_data
}

# Output the EC2 instance details
output "public_ec2_instance_id" {
  value       = aws_instance.public_ec2[0].id
  description = "The ID of the public EC2 instance"
}

output "public_ec2_instance_public_ip" {
  value       = aws_instance.public_ec2[0].public_ip
  description = "The public IP address of the public EC2 instance"
}

output "public_ec2_instance_public_dns" {
  value       = aws_instance.public_ec2[0].public_dns
  description = "The public DNS of the public EC2 instance"
}
