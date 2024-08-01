# EC2 Instance
resource "aws_instance" "public_ec2" {
  ami           = "ami-0d8f6eb4f641ef691"  # Ubuntu 20.04 AMI ID for us-west-2, update if necessary
  instance_type = "t3.micro"
  key_name      = "orange"  # Name of your key pair

  # Security Group to allow SSH access
  vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]
  subnet_id              = aws_subnet.public_subnet_a.id  # Launch in the first public subnet

  tags = {
    Name = "${var.team_prefix}_public_ec2"
  }

  # User Data to install necessary software
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get upgrade -y
    
    # Install AWS CLI
    sudo apt-get install -y awscli
    
    # Install Terraform
    sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install -y terraform
    
    # Install Docker
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update && sudo apt-get install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Install Kubernetes tools (kubectl)
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
  EOF
}

# Output the EC2 instance details
output "public_ec2_instance_id" {
  value       = aws_instance.public_ec2.id
  description = "The ID of the public EC2 instance"
}

output "public_ec2_instance_public_ip" {
  value       = aws_instance.public_ec2.public_ip
  description = "The public IP address of the public EC2 instance"
}

output "public_ec2_instance_public_dns" {
  value       = aws_instance.public_ec2.public_dns
  description = "The public DNS of the public EC2 instance"
}
