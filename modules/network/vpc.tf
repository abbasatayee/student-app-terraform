# vpc.tf
# VPC, Subnets, Internet Gateway, and Route Tables

# Data source to fetch available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.name_prefix}-vpc"
    },
    var.common_tags
  )
}

# Public Subnets
# These subnets are used for resources that need direct internet access (e.g., Load Balancer)
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.public_subnets, each.value))
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name_prefix}-public-subnet-${index(var.public_subnets, each.value) + 1}"
      Type = "Public"
    },
    var.common_tags
  )
}

# Private Subnets
# These subnets are used for resources that should not have direct internet access (e.g., EC2 instances, RDS)
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(data.aws_availability_zones.available.names, index(var.private_subnets, each.value))

  tags = merge(
    {
      Name = "${var.name_prefix}-private-subnet-${index(var.private_subnets, each.value) + 1}"
      Type = "Private"
    },
    var.common_tags
  )
}

# Internet Gateway
# Enables internet access for resources in public subnets
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.name_prefix}-igw"
    },
    var.common_tags
  )
}

# Public Route Table
# Routes traffic from public subnets to the internet via Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-public-rt"
      Type = "Public"
    },
    var.common_tags
  )
}

# Route Table Association for Public Subnets
# Associates public subnets with the public route table
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway
# REQUIRED by AWS: NAT Gateway must have a static public IP address
# This ensures your private subnet routes remain stable even if AWS
# replaces the underlying NAT Gateway infrastructure
# Cost: FREE when attached to a running NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.name_prefix}-nat-eip"
    },
    var.common_tags
  )

  depends_on = [aws_internet_gateway.gw]
}

# NAT Gateway
# AWS-managed service providing high-availability NAT for private subnets
# Benefits over NAT Instance:
# - 99.99% availability SLA with automatic failover
# - Scales automatically up to 45 Gbps
# - No maintenance, patching, or monitoring required
# - More cost-effective for production workloads
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = [for subnet in aws_subnet.public : subnet.id][0]

  tags = merge(
    {
      Name = "${var.name_prefix}-nat-gw"
    },
    var.common_tags
  )

  depends_on = [aws_internet_gateway.gw]
}

# Private Route Table
# Routes traffic from private subnets to the internet via NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-private-rt"
      Type = "Private"
    },
    var.common_tags
  )
}

# Route Table Association for Private Subnets
# Associates private subnets with the private route table
resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
