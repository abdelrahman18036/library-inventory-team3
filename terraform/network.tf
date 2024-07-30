resource "aws_vpc" "team3_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "team3_vpc"
  }
}

resource "aws_subnet" "team3_public_subnet" {
  vpc_id                   = aws_vpc.team3_vpc.id
  cidr_block               = "10.0.1.0/24"
  map_public_ip_on_launch  = true
  availability_zone        = "us-west-2a"
  tags = {
    Name = "team3_public_subnet"
    "kubernetes.io/cluster/team3-library-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "team3_private_subnet" {
  vpc_id                   = aws_vpc.team3_vpc.id
  cidr_block               = "10.0.2.0/24"
  map_public_ip_on_launch  = false
  availability_zone        = "us-west-2b"
  tags = {
    Name = "team3_private_subnet"
    "kubernetes.io/cluster/team3-library-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_security_group" "team3_eks_control_plane_sg" {
  name        = "team3_eks_control_plane_sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.team3_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "team3_eks_control_plane_sg"
  }
}

resource "aws_security_group" "team3_eks_nodes_sg" {
  name        = "team3_eks_nodes_sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.team3_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "team3_eks_nodes_sg"
  }
}

resource "aws_internet_gateway" "team3_igw" {
  vpc_id = aws_vpc.team3_vpc.id
  tags = {
    Name = "team3_igw"
  }
}

resource "aws_route_table" "team3_public_route_table" {
  vpc_id = aws_vpc.team3_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.team3_igw.id
  }

  tags = {
    Name = "team3_public_route_table"
  }
}

resource "aws_route_table_association" "team3_public_route_association" {
  subnet_id      = aws_subnet.team3_public_subnet.id
  route_table_id = aws_route_table.team3_public_route_table.id
}

resource "aws_eip" "team3_nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "team3_nat_gateway" {
  allocation_id = aws_eip.team3_nat_eip.id
  subnet_id     = aws_subnet.team3_public_subnet.id
  tags = {
    Name = "team3_nat_gateway"
  }
}

resource "aws_route_table" "team3_private_route_table" {
  vpc_id = aws_vpc.team3_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.team3_nat_gateway.id
  }

  tags = {
    Name = "team3_private_route_table"
  }
}

resource "aws_route_table_association" "team3_private_route_association" {
  subnet_id      = aws_subnet.team3_private_subnet.id
  route_table_id = aws_route_table.team3_private_route_table.id
}
