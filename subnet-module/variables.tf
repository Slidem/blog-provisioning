variable "vpc_id" {

  type = string
}

variable "cidr_block_prefix" {

  default = "10."
}

variable "vpc_cidr_block" {

  type = string
}


variable "is_public" {

  type    = string
  default = "true"
}

variable "route_table_id" {

  type = string
}

variable "subnet_index_per_availability_zones" {

  type = map(number)
}