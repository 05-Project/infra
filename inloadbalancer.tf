resource "aws_lb" "project05-controltarget-lb" {
  name               = "project05-controltarget-lb"
  internal           = true
  load_balancer_type = "network"
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
  name     = "project05-nlb-target"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_default_vpc.project05_VPC.id
  deregistration_delay = 400
  tags = {
    Name = "project05-nlb-target"
  }
}

resource "aws_lb_target_group_attachment" "project05-attach-control01" {
  target_group_arn = aws_lb_target_group.project05-nlb-target.arn
  target_id        = aws_instance.k8s_control_plane_01.id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "project05-attach-control02" {
  target_group_arn = aws_lb_target_group.project05-nlb-target.arn
  target_id        = aws_instance.k8s_control_plane_02.id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "project05-attach-control03" {
  target_group_arn = aws_lb_target_group.project05-nlb-target.arn
  target_id        = aws_instance.k8s_control_plane_03.id
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
  name   = "control-plane-lb"
  vpc_id = aws_default_vpc.project05_VPC.id
}
