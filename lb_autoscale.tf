resource "aws_autoscaling_attachment" "project05-as-attachment" {
  autoscaling_group_name = aws_autoscaling_group.project-05-node-scale-group.id
  lb_target_group_arn    = aws_lb_target_group.project05-alb-target.arn
}

resource "aws_launch_template" "project-05-node-launch" {
  name_prefix   = "node-launch-config"
  image_id      = var.ami_id
  instance_type = "t3.medium"
}

resource "aws_autoscaling_group" "project-05-node-scale-group" {
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  launch_template {
    id      = aws_launch_template.project-05-node-launch.id
    version = "$Latest"
  }
  vpc_zone_identifier = [
    aws_subnet.private_k8s_01.id,
    aws_subnet.private_k8s_02.id,
    aws_subnet.private_k8s_03.id,
  ]
}

resource "aws_security_group" "alb-sg" {
  name   = "alb-sg"
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.k8s_node_server.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.k8s_node_server.id]
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