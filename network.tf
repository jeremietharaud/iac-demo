# VPC Creation
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"

  tags = merge(var.tags, map("Name", "${local.resource_name}-VPC"))

  lifecycle {
    create_before_destroy = "true"
  }
}

# Remove default security group rules
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

# Internet gateway creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, map("Name", "${local.resource_name}-VPC"))
}

# public subnet creation
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.azs)
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = "true"

  tags = merge(var.tags, map("Name", "${local.resource_name}-PUBLIC"))
}

# public subnet route table creation
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, map("Name", "${local.resource_name}-PUBLIC"))
}

# public route creation
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# public subnet route table association
resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route53_zone" "zone" {
  name = var.domain_name

  tags = var.tags
}