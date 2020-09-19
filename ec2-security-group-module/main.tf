locals {

  known_ips_cidr_block              = var.own_ip == "" ? "0.0.0.0/0" : "${var.own_ip}/32"
  blog_instance_security_group_name = "blog_instances_security_group"
  blog_alb_security_group_name      = "alb_security_group"
}

resource "aws_security_group" "blog_instances_security_group" {

  vpc_id      = var.vpc_id
  name        = local.blog_instance_security_group_name
  description = "blog ec2 instances security group"

  egress {
    cidr_blocks = [
      "0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = [local.known_ips_cidr_block]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  tags = {
    Name = local.blog_instance_security_group_name
  }
}

resource "aws_security_group" "blog_alb_security_group" {

  vpc_id      = var.vpc_id
  name        = local.blog_alb_security_group_name
  description = "blog ec2 instances load balancer security group"

  # allow outbound traffic to instances
  egress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [
      aws_security_group.blog_instances_security_group.id]
  }

  # only accept connections on https
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  tags = {
    Name = local.blog_alb_security_group_name
  }
}

# this allows only load balancer to access the blog instances on port 80
resource "aws_security_group_rule" "allow_known_ips_and_alb_http_traffic" {
  protocol                 = "tcp"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  # from alb
  source_security_group_id = aws_security_group.blog_alb_security_group.id
  # to ec2 instances
  security_group_id        = aws_security_group.blog_instances_security_group.id
}