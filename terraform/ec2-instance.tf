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
  count = var.manage_ec2 ? 1 : 0
  ami                    = "ami-0aff18ec83b712f05"
  instance_type          = "t3.medium"
  key_name               = "orange"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
  }

  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
  subnet_id              = aws_subnet.public_subnet_a.id

  tags = {
    Name        = "${var.team_prefix}_public_ec2"
    Environment = "protected"
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

    # Create a script to manage Jenkins
    echo '#!/bin/bash
    JENKINS_PORT=8080
    echo "Checking if Jenkins is running on port \$JENKINS_PORT..."
    PID=\$(sudo lsof -t -i :\$JENKINS_PORT)
    if [ -n "\$PID" ]; then
        echo "Jenkins is running with PID \$PID. Stopping the existing instance..."
        sudo kill -9 \$PID
        echo "Existing Jenkins instance stopped."
    else
        echo "No existing Jenkins instance running on port \$JENKINS_PORT."
    fi
    echo "Starting Jenkins on port \$JENKINS_PORT..."
    nohup java -jar /usr/share/java/jenkins.war --httpPort=\$JENKINS_PORT > jenkins.log 2>&1 &
    echo "Jenkins started. Check jenkins.log for details."
    NEW_PID=\$(sudo lsof -t -i :\$JENKINS_PORT)
    echo "Jenkins is running with PID \$NEW_PID."
    ' > /home/ubuntu/start_jenkins.sh
    sudo chmod +x /home/ubuntu/start_jenkins.sh
    sudo /home/ubuntu/start_jenkins.sh

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

    # Create groups and manage permissions
    sudo groupadd docker
    sudo groupadd awscli
    sudo groupadd terraform
    sudo groupadd kubectl
    sudo groupadd trivy
    sudo groupadd helm

    sudo usermod -aG docker,awscli,terraform,kubectl,trivy,helm jenkins

    sudo chgrp docker /usr/bin/docker
    sudo chmod g+rx /usr/bin/docker

    sudo chgrp awscli /usr/local/bin/aws
    sudo chmod g+rx /usr/local/bin/aws

    sudo chgrp terraform /usr/bin/terraform
    sudo chmod g+rx /usr/bin/terraform

    sudo chgrp kubectl /usr/local/bin/kubectl
    sudo chmod g+rx /usr/local/bin/kubectl

    sudo chgrp trivy /usr/bin/trivy
    sudo chmod g+rx /usr/bin/trivy

    sudo chgrp helm /usr/local/bin/helm
    sudo chmod g+rx /usr/local/bin/helm

    sudo systemctl restart jenkins

    # Write paths to a file
    echo "Terraform: \$(sudo which terraform)" > /home/ubuntu/tool_paths.txt
    echo "AWS CLI: \$(sudo which aws)" >> /home/ubuntu/tool_paths.txt
    echo "kubectl: \$(sudo which kubectl)" >> /home/ubuntu/tool_paths.txt
    echo "Trivy: \$(sudo which trivy)" >> /home/ubuntu/tool_paths.txt
    echo "Helm: \$(sudo which helm)" >> /home/ubuntu/tool_paths.txt
    echo "Jenkins: \$(sudo which jenkins)" >> /home/ubuntu/tool_paths.txt

    # Add Jenkins initialAdminPassword to tool_paths.txt
    echo "Jenkins initialAdminPassword: \$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)" >> /home/ubuntu/tool_paths.txt
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
