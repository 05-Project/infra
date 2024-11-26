resource "aws_security_group" "k8s_internal_lb" {
  name   = "k8s_internal_lb"
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_security_group_rule" "k8s_internal_lb_kubectl_in" {
  security_group_id = aws_security_group.k8s_internal_lb.id
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "k8s_internal_lb_kubectl_out" {
  security_group_id = aws_security_group.k8s_internal_lb.id
  type              = "egress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_lb" "k8s_internal_lb" {
  name                             = "k8s-internal-lb"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 400
  subnets = [
    aws_subnet.private_k8s_01.id,
    aws_subnet.private_k8s_02.id,
    aws_subnet.private_k8s_03.id,
  ]
  security_groups = [
    aws_security_group.k8s_internal_lb.id,
  ]
  tags = {
    Name = "k8s-internal-lb"
  }
}

resource "aws_lb_target_group" "k8s_internal_lb_kubectl" {
  name        = "k8s-internal-lb-kubectl"
  target_type = "ip"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_default_vpc.project05_VPC.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTPS"
    path                = "/healthz"
  }
  tags = {
    Name = "k8s-internal-lb-kubectl"
  }
}

resource "aws_lb_target_group_attachment" "k8s_internal_lb_control_01" {
  target_group_arn = aws_lb_target_group.k8s_internal_lb_kubectl.arn
  target_id        = aws_instance.k8s_control_plane_01.private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "k8s_internal_lb_control_02" {
  target_group_arn = aws_lb_target_group.k8s_internal_lb_kubectl.arn
  target_id        = aws_instance.k8s_control_plane_02.private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "k8s_internal_lb_control_03" {
  target_group_arn = aws_lb_target_group.k8s_internal_lb_kubectl.arn
  target_id        = aws_instance.k8s_control_plane_03.private_ip
  port             = 6443
}

resource "aws_lb_listener" "k8s_internal_lb_kubectl" {
  load_balancer_arn = aws_lb.k8s_internal_lb.arn
  port              = 6443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_internal_lb_kubectl.arn
  }
}
