resource "aws_lb_target_group" "project05-alb-target" {
  name        = "project05-alb-target"
  target_type = "alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.project05_VPC.id

  tags = {
    Name = "project05-alb-target"
  }
}

resource "aws_lb" "project05-nodetarget-lb" {
  name               = "project05-nodetarget-lb"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.private_k8s_01.id,
    aws_subnet.private_k8s_02.id,
    aws_subnet.private_k8s_03.id
  ]

  tags = {
    Name = "project05-nodetarget-lb"
  }
}

resource "aws_lb_target_group_attachment" "project05-attach-node01" {
  target_group_arn = aws_lb_target_group.project05-alb-target.arn
  target_id        = aws_instance.node01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "project05-attach-node02" {
  target_group_arn = aws_lb_target_group.project05-alb-target.arn
  target_id        = aws_instance.node02.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "project05-attach-node03" {
  target_group_arn = aws_lb_target_group.project05-alb-target.arn
  target_id        = aws_instance.node03.id
  port             = 80
}

resource "aws_lb_listener" "node-ln" {
  load_balancer_arn = aws_lb.project05-nodetarget-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project05-alb-target.arn
  }
}