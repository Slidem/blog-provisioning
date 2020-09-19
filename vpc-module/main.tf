# Main vpc
resource "aws_vpc" "blog_main_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "blog-main"
  }
}


# internet gateway for the vpc created
# allows inbound and outbound traffic to / from our public instances
resource "aws_internet_gateway" "blog_main_gateway" {

  vpc_id = aws_vpc.blog_main_vpc.id
  tags = {
    Name = "blog-main"
  }
}

# route tables
resource "aws_route_table" "main-public" {

  vpc_id = aws_vpc.blog_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.blog_main_gateway.id
  }

  tags = {
    Name = "blog-main-public-route-table"
  }
}

resource "aws_route_table" "main-private" {
  vpc_id = aws_vpc.blog_main_vpc.id
  tags = {
    Name = "blog-main-private-route-table"
  }
}