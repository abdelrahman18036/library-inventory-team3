# Security Group for EC2 Instance
resource "aws_security_group" "public_ec2_sg" {
  name        = "${var.team_prefix}_public_ec2_sg"
  description = "Security group for the public EC2 instance"
  vpc_id      = aws_vpc.team_vpc.id

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

# EC2 Instance
resource "aws_instance" "public_ec2" {
  ami                    = "ami-0aff18ec83b712f05"  # Ubuntu 20.04 AMI ID for us-west-2, update if necessary
  instance_type          = "t3.micro"
  key_name               = "orange"  # Name of your key pair
  associate_public_ip_address = true  # Auto-assign public IP

  # Use the newly created security group
  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
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
    sudo apt-get install -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # Install wget and Trivy
    sudo apt-get install wget -y
    wget https://github.com/aquasecurity/trivy/releases/download/v0.42.0/trivy_0.42.0_Linux-64bit.deb
    sudo dpkg -i trivy_0.42.0_Linux-64bit.deb

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Install Jenkins
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y fontconfig openjdk-17-jre jenkins

    # Enable and start Jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins

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

    # Write paths to a file
    echo "Terraform: $(which terraform)" > /home/ubuntu/tool_paths.txt
    echo "AWS CLI: $(which aws)" >> /home/ubuntu/tool_paths.txt
    echo "kubectl: $(which kubectl)" >> /home/ubuntu/tool_paths.txt
    echo "Trivy: $(which trivy)" >> /home/ubuntu/tool_paths.txt
    echo "Helm: $(which helm)" >> /home/ubuntu/tool_paths.txt
    echo "Jenkins: $(which jenkins)" >> /home/ubuntu/tool_paths.txt
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
