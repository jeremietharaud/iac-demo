# Application Load Balancer
resource "aws_lb" "alb" {
  name                       = substr(local.resource_name, 0, 31)
  internal                   = false
  subnets                    = aws_subnet.public.*.id
  security_groups            = [aws_security_group.alb.id]
  load_balancer_type         = "application"
  idle_timeout               = "400"
  enable_deletion_protection = "false"
  enable_http2               = "true"

  tags = var.tags
}

# Security group for the ALB
resource "aws_security_group" "alb" {
  name_prefix = "${local.resource_name}-alb-"
  description = "Enable access to ${local.resource_name} ALB"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(map("Name", "${local.resource_name}-alb"), var.tags)

  lifecycle {
    create_before_destroy = "true"
  }
}

# Ingress rule for incoming traffic from any to ALB
resource "aws_security_group_rule" "ingress_alb_from_any" {
  description = "Incoming traffic from anywhere"
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks

  security_group_id = aws_security_group.alb.id
}

# Ingress rule for https incoming traffic from any to ALB
resource "aws_security_group_rule" "ingress_https_from_any" {
  description = "Incoming traffic from anywhere"
  type        = "ingress"
  from_port   = "443"
  to_port     = "443"
  protocol    = "tcp"
  cidr_blocks = var.cidr_blocks

  security_group_id = aws_security_group.alb.id
}

# Egress rule for outgoing traffic to anywhere
resource "aws_security_group_rule" "egress_alb" {
  description = "Outgoing traffic"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb.id
}

# Listener for the ALB
resource "aws_lb_listener" "alb_listener_80" {
  count             = var.force_https == "true" ? 0 : 1
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

# Default Target group used by the ALB
resource "aws_lb_target_group" "default" {
  name     = "${substr(local.resource_name, 0, 20)}-tg"
  protocol = "HTTP"
  port     = var.application_port
  vpc_id   = aws_vpc.vpc.id

  tags = var.tags
}

# HTTPS listener for the ALB
resource "aws_lb_listener" "alb_listener_443" {
  count = var.force_https == "true" ? 1 : 0
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn
}

# Route53 record in front of ALB
resource "aws_route53_record" "www" {
  name    = var.domain_name
  zone_id = aws_route53_zone.zone.zone_id
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
  }
}