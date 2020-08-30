locals {

  allocated_storage = 10
  instance_class    = "db.t2.micro"
  db_identifier     = "${var.db_name}db"
  db_port_str       = tostring(var.db_port)
}

resource "aws_db_instance" "my_database_instance" {
  allocated_storage      = local.allocated_storage
  storage_type           = "gp2"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = local.instance_class
  port                   = local.db_port_str
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.my_database_subnet_group.name
  name                   = var.db_name
  identifier             = local.db_identifier
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  tags = {
    Name = "blog_database_instance"
  }
}

module "subnet" {

  subnet_index_per_availability_zones = var.subnet_index_per_availability_zones

  source         = "../subnet-module"
  vpc_id         = var.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  route_table_id = var.private_route_table_id
  is_public      = "false"
}

resource "aws_db_subnet_group" "my_database_subnet_group" {
  name       = "blog-db-subnet-group"
  subnet_ids = module.subnet.subnet_ids

  tags = {
    Name = "blog_db_subnet_group"
  }
}

resource "aws_security_group" "database" {

  vpc_id      = var.vpc_id
  name        = "allow_database"
  description = "Allow database access"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = var.db_port
    protocol    = "tcp"
    to_port     = var.db_port
  }
}

