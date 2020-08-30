output "alb_dns_name" {
  value = aws_alb.blog_alb.dns_name
}

output "alb_zone_id" {
  value = aws_alb.blog_alb.zone_id
}

output "alb_arn" {
  value = aws_alb.blog_alb.arn
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.blog_target_group.arn
}