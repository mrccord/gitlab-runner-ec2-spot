output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "route_table_id" {
  value = aws_route_table.public-route-table.id
}

output "default_route_table_id" {
  value = aws_vpc.main-vpc.default_route_table_id
}
