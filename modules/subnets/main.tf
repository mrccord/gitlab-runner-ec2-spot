resource "aws_subnet" "public-subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "gitlab-runner-public-subnet"
  }
}

resource "aws_route_table_association" "route-table-assoc" {
  route_table_id = var.route_table_id
  subnet_id      = aws_subnet.public-subnet.id
}

resource "aws_eip" "eip-vpc" {
  vpc = true
  tags = {
    Name = "gitlab-runner-eip-vpc"
  }
}

resource "aws_nat_gateway" "nat-gateway-subnet" {
  allocation_id = aws_eip.eip-vpc.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "gitlab-runner-nat-gateway"
  }
}

resource "aws_default_route_table" "default-route-table-nat" {
  default_route_table_id = var.default_route_table_id

  route {
    nat_gateway_id = aws_nat_gateway.nat-gateway-subnet.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "gitlab-runner-default-route-table"
  }
}
