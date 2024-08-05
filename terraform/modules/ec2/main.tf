resource "aws_security_group" "public_ec2_sg" {
  name        = "${var.team_prefix}_public_ec2_sg"
  description = "Security group for the public EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
  key_name               = "orange"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
  }

  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
  subnet_id              = var.public_subnet_id

  tags = {
    Name        = "${var.team_prefix}_public_ec2"
    Environment = "protected"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get upgrade -y

    sudo apt-get install -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    sudo apt-get install wget -y
    wget https://github.com/aquasecurity/trivy/releases/download/v0.42.0/trivy_0.42.0_Linux-64bit.deb
    sudo dpkg -i trivy_0.42.0_Linux-64bit.deb

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y fontconfig openjdk-17-jre jenkins

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

    sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install -y terraform
    
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update && sudo apt-get install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

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

    echo "Terraform: \$(sudo which terraform)" > /home/ubuntu/tool_paths.txt
    echo "AWS CLI: \$(sudo which aws)" >> /home/ubuntu/tool_paths.txt
    echo "kubectl: \$(sudo which kubectl)" >> /home/ubuntu/tool_paths.txt
    echo "Trivy: \$(sudo which trivy)" >> /home/ubuntu/tool_paths.txt
    echo "Helm: \$(sudo which helm)" >> /home/ubuntu/tool_paths.txt
    echo "Jenkins: \$(sudo which jenkins)" >> /home/ubuntu/tool_paths.txt

    echo "Jenkins initialAdminPassword: \$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)" >> /home/ubuntu/tool_paths.txt
  EOF
}
