data "aws_ami" "latest-ubuntu" {

  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "instance_public_subnets" {

  subnet_index_per_availability_zones = var.subnet_index_per_availability_zones

  source         = "../subnet-module"
  vpc_id         = var.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  route_table_id = var.public_route_table_id
}

resource "aws_instance" "blog_instance" {

  for_each = var.subnet_index_per_availability_zones

  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = "t2.micro"

  # public subnet
  subnet_id = module.instance_public_subnets.subnet_ids_per_availability_zone[each.key]

  # the public SSH key
  key_name = var.ssh_key_name

  # the security group
  vpc_security_group_ids = var.instance_security_groups

  provisioner "remote-exec" { #install apache, mysql client, php
    inline = [
      "sudo export DB_HOST=\"${var.db_host}\"",
      "sudo export DB_PORT=\"${var.db_port}\"",
      "sudo export DB_USERNAME=\"${var.db_username}\"",
      "sudo export DB_PASSWORD=\"${var.db_password}\"",
      "sudo mkdir -p /var/www/html/",
      "sudo apt update -y",
      "sudo apt install apache2 -y",
      "sudo /etc/init.d/apache2 start -y",
      "sudo chown -R ubuntu:ubuntu /var/www",
      "sudo apt-get install mysql-client -y",
      "sudo apt install php libapache2-mod-php php-mysql -y"
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
    type = "lb_cookie"
    cookie_duration = 120
    enabled = true
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



