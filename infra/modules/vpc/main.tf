# Local variables for additional tags
locals {
  additional_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Resource
resource "aws_vpc" "todoapp-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-${var.environment}-vpc" }
  )
}


# Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.todoapp-vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.tags,
    { "Name" = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}" }
  )
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.todoapp-vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 10 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.tags,
    local.additional_tags,
    { "Name" = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}" }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "todoapp_igw" {
  vpc_id = aws_vpc.todoapp-vpc.id
  tags = merge(
    var.tags,
    { Name = "${var.project_name}-${var.environment}-igw" }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "todoapp_ngw_eip" {
  domain = "vpc"
  tags = merge(
    var.tags,
    { Name = "${var.project_name}-${var.environment}-eip" }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "todoapp_ngw" {
  allocation_id = aws_eip.todoapp_ngw_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge(
    var.tags,
    { Name = "${var.project_name}-${var.environment}-ngw" }
  )
  depends_on = [aws_internet_gateway.todoapp_igw]
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.todoapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.todoapp_igw.id
  }

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-${var.environment}-public-rt" }
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.todoapp-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.todoapp_ngw.id
  }

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-${var.environment}-private-rt" }
  )
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
