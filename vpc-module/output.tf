output "vpc_id" {
  value = aws_vpc.blog_main_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.blog_main_vpc.cidr_block
}

output "internet_gateway_id" {

  value = aws_internet_gateway.blog_main_gateway.id
}

output "public_route_table" {

  value = aws_route_table.main-public.id
}

output "private_route_table_id" {

  value = aws_route_table.main-private.id
}