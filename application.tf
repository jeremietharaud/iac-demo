resource "aws_key_pair" "key" {
  key_name   = "${local.resource_name}-keypair"
  public_key = var.public_key
}

resource "aws_launch_configuration" "instances" {
  name_prefix                 = "${local.resource_name}-"
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.key.key_name
  security_groups             = [aws_security_group.instances.id]
  instance_type               = var.instance_type
  image_id                    = data.aws_ami.ubuntu.id

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.tpl", {}))
}

resource "aws_autoscaling_group" "instances" {
  name_prefix          = "${local.resource_name}-"
  vpc_zone_identifier  = aws_subnet.public.*.id
  min_size             = var.asg_instances_min_size
  max_size             = var.asg_instances_max_size
  desired_capacity     = var.asg_instances_desired_capacity
  termination_policies = ["OldestInstance", "Default"]

  launch_configuration = aws_launch_configuration.instances.name

  target_group_arns = [aws_lb_target_group.default.arn]

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instances" {
  name_prefix = "${local.resource_name}-"
  description = "SG for instances of ${local.resource_name}"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(var.tags, map("Name", local.resource_name))

  lifecycle {
    create_before_destroy = "true"
  }
}

# Ingress rule from ALB to instances
resource "aws_security_group_rule" "ingress_alb_instance" {
  description = "Incoming traffic from ALB to ${local.resource_name}"
  type        = "ingress"
  from_port   = var.application_port
  to_port     = var.application_port
  protocol    = "TCP"

  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.instances.id
}

resource "aws_security_group_rule" "ingress_ssh" {
  description       = "Incoming SSH traffic to ${local.resource_name}"
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "TCP"
  cidr_blocks       = var.cidr_blocks
  security_group_id = aws_security_group.instances.id
}

# Egress rule from instances to anywhere
resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instances.id
}
