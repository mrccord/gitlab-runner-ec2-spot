resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "gitlab-runner-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "gitlab-runner-igw"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "gitlab-runner-public-route-table"
  }
}
