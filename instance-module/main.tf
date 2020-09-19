locals {
  // ubuntu 20.04 LTS
  latest_ubuntu_ami_id = "ami-06f7efb202729c3c5"
}

module "instance_public_subnets" {

  subnet_index_per_availability_zones = var.subnet_index_per_availability_zones

  source         = "../subnet-module"
  vpc_id         = var.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  route_table_id = var.public_route_table_id
}

resource "aws_s3_bucket" "blog-media-content-bucket" {
  bucket = "blog-media-content-bucket"
  acl    = "private"
  tags   = {
    Name        = "Blog media content bucket"
    Environment = "Blog"
  }
}

module "ec2_s3_policy" {
  source  = "../ec2-s3-policy"
  buckets = [
    aws_s3_bucket.blog-media-content-bucket.bucket]
}

module "ec2_iam_profile" {
  source           = "../iam-instance-profile"
  iam_policies_arn = [
    module.ec2_s3_policy.buckets_policy_arn]
  role_name        = "blog-instance-iam-role"

  depends_on = [
    module.ec2_s3_policy]
}

resource "aws_instance" "blog_instance" {

  for_each = var.subnet_index_per_availability_zones

  ami           = local.latest_ubuntu_ami_id
  instance_type = "t2.micro"

  # public subnet
  subnet_id = module.instance_public_subnets.subnet_ids_per_availability_zone[each.key]

  # the public SSH key
  key_name = var.ssh_key_name

  # the security group
  vpc_security_group_ids = var.instance_security_groups

  iam_instance_profile = module.ec2_iam_profile.blog_instance_profile_name

  provisioner "file" {
    source      = "./instance-module/install-apache.sh"
    destination = "/tmp/install-apache.sh"
  }

  provisioner "file" {
    source      = "./instance-module/install-php.sh"
    destination = "/tmp/install-php.sh"
  }

  provisioner "file" {
    source      = "./instance-module/install-wp-cli.sh"
    destination = "/tmp/install-wp-cli.sh"
  }

  provisioner "file" {
    source      = "./instance-module/install-wp.sh"
    destination = "/tmp/install-wp.sh"
  }

  provisioner "file" {
    source      = "./instance-module/install-wp-s3-plugin.sh"
    destination = "/tmp/install-wp-s3-plugin.sh"
  }

  provisioner "file" {
    source      = "./instance-module/resolve_mixed_content.txt"
    destination = "/tmp/resolve_mixed_content.txt"
  }

  provisioner "remote-exec" {
    #install apache, mysql client, php
    inline = [
      "export DB_USERNAME=${var.db_username}",
      "export DB_PASSWORD=${var.db_password}",
      "export DB_HOST=${var.db_host}",
      "export WP_URL=${var.wp_url}",
      "export WP_BLOG_TITLE=${var.blog_title}",
      "export WP_ADMIN_USERNAME=${var.wp_admin_username}",
      "export WP_ADMIN_PASSWORD=${var.wp_admin_password}",
      "export WP_ADMIN_EMAIL=${var.wp_admin_email}",
      "chmod +x /tmp/install-apache.sh",
      "chmod +x /tmp/install-php.sh",
      "chmod +x /tmp/install-wp-cli.sh",
      "chmod +x /tmp/install-wp.sh",
      "chmod +x /tmp/install-wp-s3-plugin.sh",
      "sudo /tmp/install-apache.sh",
      "sudo /tmp/install-php.sh",
      "/tmp/install-wp-cli.sh",
      "/tmp/install-wp.sh",
      "/tmp/install-wp-s3-plugin.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.path_to_private_key)
  }
}

resource "aws_alb" "blog_alb" {

  name               = "blog-alb"
  load_balancer_type = "application"
  subnets            = module.instance_public_subnets.subnet_ids
  security_groups    = var.alb_security_group_id

  depends_on = [
    aws_instance.blog_instance
  ]
}

resource "aws_alb_target_group" "blog_target_group" {

  name     = "blog-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 900
    enabled         = true
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    path                = "/"
    port                = 80
  }

  depends_on = [
    aws_instance.blog_instance
  ]
}

resource "aws_alb_target_group_attachment" "blog_attachment" {

  for_each = var.subnet_index_per_availability_zones

  target_group_arn = aws_alb_target_group.blog_target_group.arn
  target_id        = aws_instance.blog_instance[each.key].id
  port             = 80

  depends_on = [
    aws_instance.blog_instance
  ]
}



