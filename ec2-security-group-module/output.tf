output "ec2_instance_security_group_ids" {
  value = [aws_security_group.blog_instances_security_group.id]
}

output "alb_security_group" {
  value = [aws_security_group.blog_alb_security_group.id]
}
