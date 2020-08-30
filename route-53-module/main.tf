# dns zone already created
# registration of the dnz domain is done before hand, as this step should not
# be automated
data "aws_route53_zone" "public" {
  name         = var.blog_dns_zone
  private_zone = false
}


# create a dns record for the blog
resource "aws_route53_record" "blog" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "blog.${var.blog_dns_zone}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Create ssl certificate for load balancer
resource "aws_acm_certificate" "blog" {
  domain_name       = var.blog_dns_zone
  validation_method = "DNS"
  subject_alternative_names = [
  "*.${var.blog_dns_zone}"]
}

locals {
  domain_validation_options = tolist(aws_acm_certificate.blog.domain_validation_options)
}

# DNS record for the ACM certificate validation to prove we own the domain
resource "aws_route53_record" "cert_validation" {
  name    = local.domain_validation_options[0].resource_record_name
  type    = local.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.public.id
  records = [
  local.domain_validation_options[0].resource_record_value]
  ttl = 60
}

# trigger validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.blog.arn
  validation_record_fqdns = [
  aws_route53_record.cert_validation.fqdn]
}


resource "aws_alb_listener" "blog-listeners" {

  port              = "443"
  protocol          = "HTTPS"
  load_balancer_arn = var.alb_arn
  certificate_arn   = aws_acm_certificate.blog.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = var.alb_target_group_arn
    type             = "forward"
  }
}