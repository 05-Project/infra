resource "aws_lb" "project05-controltarget-lb" {
  name                             = "project05-controltarget-lb"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 400
  subnets = [
    aws_subnet.private_k8s_01.id,
    aws_subnet.private_k8s_02.id,
    aws_subnet.private_k8s_03.id
  ]
  security_groups = [
    aws_security_group.kubectl_lb.id,
  ]
  tags = {
    Name = "project05-controltarget-lb"
  }
}

resource "aws_lb_target_group" "project05-nlb-target" {
  name        = "project05-nlb-target"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_default_vpc.project05_VPC.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTPS"
    path                = "/healthz"
  }
  tags = {
    Name = "project05-nlb-target"
  }
}

resource "aws_lb_target_group_attachment" "project05-attach-control01" {
  target_group_arn = aws_lb_target_group.project05-nlb-target.arn
  target_id        = aws_instance.k8s_control_plane_01.private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "project05-attach-control02" {
  target_group_arn = aws_lb_target_group.project05-nlb-target.arn
  target_id        = aws_instance.k8s_control_plane_02.private_ip
  port             = 6443
}

resource "aws_lb_target_group_attachment" "project05-attach-control03" {
  target_group_arn = aws_lb_target_group.project05-nlb-target.arn
  target_id        = aws_instance.k8s_control_plane_03.private_ip
  port             = 6443
}

resource "aws_lb_listener" "control-plane-ln" {
  load_balancer_arn = aws_lb.project05-controltarget-lb.arn
  port              = 6443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project05-nlb-target.arn
  }
}

resource "aws_security_group" "kubectl_lb" {
  name   = "kubectl_lb"
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_security_group_rule" "kubectl_lb_in" {
  security_group_id = aws_security_group.kubectl_lb.id
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "kubectl_lb_out" {
  security_group_id = aws_security_group.kubectl_lb.id
  type              = "egress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
