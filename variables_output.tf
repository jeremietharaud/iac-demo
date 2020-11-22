output "load_balancer_url" {
  value = var.force_https == "true" ? "https://${aws_lb.alb.dns_name}" : "http://${aws_lb.alb.dns_name}"
}

output "url" {
  value = var.force_https == "true" ? "https://${aws_route53_record.www.name}" : "http://${aws_route53_record.www.name}"
}
