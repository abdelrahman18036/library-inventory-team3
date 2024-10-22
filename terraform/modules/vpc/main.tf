# Declare the aws_availability_zones data source
data "aws_availability_zones" "available" {}

# VPC Resource
resource "aws_vpc" "team_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.team_prefix}_vpc"
  }
}

# Public Subnet A
resource "aws_subnet" "public_subnet_a" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.public_subnet_cidr_a
  map_public_ip_on_launch  = true
  availability_zone        = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.team_prefix}_public_subnet_a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# Public Subnet B
resource "aws_subnet" "public_subnet_b" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.public_subnet_cidr_b
  map_public_ip_on_launch  = true
  availability_zone        = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.team_prefix}_public_subnet_b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnet A
resource "aws_subnet" "private_subnet_a" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.private_subnet_cidr_a
  map_public_ip_on_launch  = false
  availability_zone        = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.team_prefix}_private_subnet_a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private Subnet B
resource "aws_subnet" "private_subnet_b" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.private_subnet_cidr_b
  map_public_ip_on_launch  = false
  availability_zone        = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.team_prefix}_private_subnet_b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}


resource "aws_security_group" "eks_control_plane_sg" {
  name        = "${var.team_prefix}_eks_control_plane_sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.team_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Name = "${var.team_prefix}_eks_control_plane_sg"
  }
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.team_prefix}_eks_nodes_sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.team_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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
    Name = "${var.team_prefix}_eks_nodes_sg"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.team_vpc.id
  tags = {
    Name = "${var.team_prefix}_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.team_prefix}_public_route_table"
  }
}

resource "aws_route_table_association" "public_route_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "${var.team_prefix}_nat_gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.team_prefix}_private_route_table"
  }
}

resource "aws_route_table_association" "private_route_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}
