resource "aws_subnet" "subnet" {

  for_each = var.subnet_index_per_availability_zones

  vpc_id                  = var.vpc_id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, each.value)
  map_public_ip_on_launch = var.is_public
  tags = {
    Name = "blog-main-${each.key}"
  }
}

# route association
resource "aws_route_table_association" "blog-main" {

  for_each = var.subnet_index_per_availability_zones

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = var.route_table_id
}

locals {

  subnet_ids                       = [for x in aws_subnet.subnet : x.id]
  subnet_ids_per_availability_zone = { for subnet in aws_subnet.subnet : subnet.availability_zone => subnet.id }
}