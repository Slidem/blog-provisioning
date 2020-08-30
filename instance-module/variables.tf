variable "ssh_key_name" {

  type = string
}

variable "path_to_private_key" {

  type = string
}

variable "vpc_id" {

  type = string
}

variable "vpc_cidr_block" {

  type = string
}

variable "public_route_table_id" {

  type = string
}

variable "instance_security_groups" {

  type = list(string)
}
variable "alb_security_group_id" {

  type = list(string)
}


variable db_host {

  type = string
}

variable db_port {

  type = string
}

variable db_username {

  type = string
}

variable db_password {

  type = string
}

variable "subnet_index_per_availability_zones" {

  type = map(number)
}