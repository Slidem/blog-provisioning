provider "aws" {
  region = var.AWS_REGION
}

module "blog_vpc" {
  source = "./vpc-module"
}

module "security_groups" {
  source = "./ec2-security-group-module"
  vpc_id = module.blog_vpc.vpc_id
  own_ip = var.MY_IP_ADDRESS
}

resource "aws_key_pair" "aws_instance_key" {

  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

module "blog_rds" {
  source                 = "./rds-module"
  private_route_table_id = module.blog_vpc.private_route_table_id
  vpc_id                 = module.blog_vpc.vpc_id
  vpc_cidr_block         = module.blog_vpc.vpc_cidr_block
  subnet_index_per_availability_zones = {
    "eu-west-1a" : 1,
    "eu-west-1b" : 2
  }
  db_port     = 3306
  db_name     = var.DB_NAME
  db_username = var.DB_USERNAME
  db_password = var.DB_PASSWORD
}

module "blog_instances" {
  source = "./instance-module"

  vpc_id                = module.blog_vpc.vpc_id
  vpc_cidr_block        = module.blog_vpc.vpc_cidr_block
  public_route_table_id = module.blog_vpc.public_route_table
  subnet_index_per_availability_zones = {
    "eu-west-1a" : 3,
    "eu-west-1b" : 4
  }

  instance_security_groups = module.security_groups.ec2_instance_security_group_ids
  alb_security_group_id    = module.security_groups.alb_security_group

  ssh_key_name        = aws_key_pair.aws_instance_key.key_name
  path_to_private_key = var.PATH_TO_PRIVATE_KEY

  db_host           = module.blog_rds.db_host
  db_port           = module.blog_rds.db_port
  db_username       = module.blog_rds.db_username
  db_password       = module.blog_rds.db_password
  wp_url            = "${var.BLOG_SUBDOMAIN}.${var.BLOG_DOMAIN}"
  wp_admin_username = var.WP_ADMIN_USERNAME
  wp_admin_password = var.WP_ADMIN_PASSWORD
  wp_admin_email    = var.WP_ADMIN_EMAIL
}

module "blog_dns" {
  source               = "./route-53-module"
  alb_dns_name         = module.blog_instances.alb_dns_name
  alb_zone_id          = module.blog_instances.alb_zone_id
  alb_arn              = module.blog_instances.alb_arn
  alb_target_group_arn = module.blog_instances.alb_target_group_arn
  blog_domain          = var.BLOG_DOMAIN
  blog_subdomain       = var.BLOG_SUBDOMAIN
}