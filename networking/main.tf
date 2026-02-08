# ============================================
# Data Sources
# ============================================

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================
# VPC and Networking
# ============================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "kubernetes-vpc"
  }
}

# SSM Parameter to store vpc id
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/eks_project/vpc_id"
  type  = "String"
  value = aws_vpc.main.id

  description = "VPC ID for EKS cluster"
  
  tags = {
    ManagedBy = "Terraform"
    Layer     = "networking"
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "kubernetes-igw"
    ManagedBy = "Terraform"
    Layer     = "networking"
  }
}

# Public Subnets (for load balancers)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "kubernetes-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
    ManagedBy = "Terraform"
    Layer     = "networking"
  }
}

# Private Subnets (for EKS nodes)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "kubernetes-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    ManagedBy = "Terraform"
    Layer     = "networking"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "kubernetes-nat-eip-${count.index + 1}"
    ManagedBy = "Terraform"
    Layer     = "networking"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (allows private subnets to access internet)
resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "kubernetes-nat-${count.index + 1}"
    ManagedBy = "Terraform"
    Layer     = "networking"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "kubernetes-public-rt"
    ManagedBy = "Terraform"
    Layer     = "networking"
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "kubernetes-private-rt-${count.index + 1}"
    ManagedBy = "Terraform"
    Layer     = "networking"
  }
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}