variable "engine" {

  default = "mysql"
}

variable "engine_version" {

  default = "8.0.20"
}

variable "db_port" {

  default = 3306
}

variable "db_name" {

  default = "wordpress"
}

variable "db_username" {

  type = string
}

variable "db_password" {

  type = string
}

variable "vpc_id" {

  type = string
}

variable "vpc_cidr_block" {

  type = string
}

variable "subnet_index_per_availability_zones" {

  type = map(number)
}

variable "private_route_table_id" {

  type = string
}