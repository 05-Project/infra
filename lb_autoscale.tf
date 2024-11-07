resource "aws_lb_target_group" "project-05-lb-target" {
  name        = "project-05-lb-target"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_default_vpc.project05_VPC.id
}

resource "aws_autoscaling_attachment" "project05-as-attachment" {
  autoscaling_group_name = aws_autoscaling_group.project-05-node-scale-group.id
  lb_target_group_arn    = aws_lb_target_group.project-05-lb-target.arn
}

resource "aws_launch_configuration" "project-05-node-launch" {
  name_prefix     = "node-launch-config"
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.node_sg.id]
}

resource "aws_autoscaling_group" "project-05-node-scale-group" {
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.project-05-node-launch.id
  vpc_zone_identifier = [
    aws_default_subnet.public_01.id,
    aws_default_subnet.public_02.id,
    aws_default_subnet.public_03.id,
    aws_default_subnet.public_04.id
  ]
}

resource "aws_lb" "project-05-kube-lb" {
  name               = "project-05-kube-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets = [
    aws_default_subnet.public_01.id,
    aws_default_subnet.public_02.id,
    aws_default_subnet.public_03.id,
    aws_default_subnet.public_04.id
  ]
}

resource "aws_lb_listener" "project05-lb-ln" {
  load_balancer_arn = aws_lb.project-05-kube-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project-05-lb-target.arn
  }
}

resource "aws_security_group" "alb-sg" {
  name   = "alb-sg"
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_internet_gateway.project05_VPC_gateway.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_internet_gateway.project05_VPC_gateway.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}