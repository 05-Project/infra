resource "aws_autoscaling_attachment" "project05-as-attachment" {
  autoscaling_group_name = aws_autoscaling_group.project-05-node-scale-group.id
  lb_target_group_arn    = aws_lb_target_group.project05-alb-target.arn
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