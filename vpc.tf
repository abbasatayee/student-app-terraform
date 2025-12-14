# vpc.tf
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "Student VPC" }
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.public_subnets, each.value))
  tags = {
    Name = "Public Subnet ${index(var.public_subnets, each.value) + 1}"
    Type = "Public"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = element(data.aws_availability_zones.available.names, index(var.private_subnets, each.value))
  tags = {
    Name = "Private Subnet ${index(var.private_subnets, each.value) + 1}"
    Type = "Private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Public Route Table",
    Type = "Public"
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "public_assoc" {
  for_each   = aws_subnet.public
  subnet_id  = each.value.id
  route_table_id = aws_route_table.public.id
}
