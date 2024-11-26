resource "aws_security_group" "k8s_external_lb" {
  name   = "k8s-external-lb"
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_security_group_rule" "k8s_external_lb_http_in" {
  security_group_id = aws_security_group.k8s_external_lb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "k8s_external_lb_https_in" {
  security_group_id = aws_security_group.k8s_external_lb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "k8s_external_lb_out" {
  security_group_id = aws_security_group.k8s_external_lb.id
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_lb" "k8s_external_lb" {
  name                             = "k8s-external-lb"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 400
  subnets = [
    aws_default_subnet.public_01.id,
    aws_default_subnet.public_02.id,
    aws_default_subnet.public_03.id,
    aws_default_subnet.public_04.id,
  ]
  security_groups = [
    aws_security_group.k8s_external_lb.id,
  ]
  tags = {
    Name = "k8s-external-lb"
  }
}

resource "aws_lb_target_group" "k8s_external_lb_http" {
  name        = "k8s-external-lb-http"
  target_type = "ip"
  port        = 31957
  protocol    = "TCP"
  vpc_id      = aws_default_vpc.project05_VPC.id
  tags = {
    Name = "k8s-external-lb-http"
  }
}

resource "aws_lb_listener" "k8s_external_lb_http" {
  load_balancer_arn = aws_lb.k8s_external_lb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_external_lb_http.arn
  }
}

resource "aws_lb_target_group_attachment" "k8s_external_lb_http_01" {
  target_group_arn = aws_lb_target_group.k8s_external_lb_http.arn
  target_id        = aws_instance.k8s_node_01.private_ip
  port             = 31957
}

resource "aws_lb_target_group_attachment" "k8s_external_lb_http_02" {
  target_group_arn = aws_lb_target_group.k8s_external_lb_http.arn
  target_id        = aws_instance.k8s_node_02.private_ip
  port             = 31957
}

resource "aws_lb_target_group_attachment" "k8s_external_lb_http_03" {
  target_group_arn = aws_lb_target_group.k8s_external_lb_http.arn
  target_id        = aws_instance.k8s_node_03.private_ip
  port             = 31957
}

resource "aws_lb_target_group" "k8s_external_lb_https" {
  name        = "k8s-external-lb-https"
  target_type = "ip"
  port        = 31123
  protocol    = "TCP"
  vpc_id      = aws_default_vpc.project05_VPC.id
  tags = {
    Name = "k8s_external_lb-https"
  }
}

resource "aws_lb_listener" "k8s_external_lb_https" {
  load_balancer_arn = aws_lb.k8s_external_lb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_external_lb_https.arn
  }
}

resource "aws_lb_target_group_attachment" "k8s_external_lb_https_01" {
  target_group_arn = aws_lb_target_group.k8s_external_lb_https.arn
  target_id        = aws_instance.k8s_node_01.private_ip
  port             = 31123
}

resource "aws_lb_target_group_attachment" "k8s_external_lb_https_02" {
  target_group_arn = aws_lb_target_group.k8s_external_lb_https.arn
  target_id        = aws_instance.k8s_node_02.private_ip
  port             = 31123
}

resource "aws_lb_target_group_attachment" "k8s_external_lb_https_03" {
  target_group_arn = aws_lb_target_group.k8s_external_lb_https.arn
  target_id        = aws_instance.k8s_node_03.private_ip
  port             = 31123
}
