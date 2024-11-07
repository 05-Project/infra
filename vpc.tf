resource "aws_default_vpc" "project05_VPC" {
  tags = {
    Name = "project05_VPC"
  }
}

resource "aws_default_subnet" "public_01" {
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "public_01"
  }
}

resource "aws_default_subnet" "public_02" {
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "public_02"
  }
}

resource "aws_default_subnet" "public_03" {
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "public_03"
  }
}

resource "aws_default_subnet" "public_04" {
  availability_zone = "ap-northeast-2d"

  tags = {
    Name = "public_04"
  }
}

resource "aws_subnet" "private_01" {
  vpc_id     = aws_default_vpc.project05_VPC.id
  cidr_block = "172.31.64.0/20"
  tags = {
    Name = "private_01"
  }
  availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "private_02" {
  vpc_id     = aws_default_vpc.project05_VPC.id
  cidr_block = "172.31.80.0/20"
  tags = {
    Name = "private_02"
  }
  availability_zone = "ap-northeast-2c"
}

resource "aws_subnet" "private_03" {
  vpc_id     = aws_default_vpc.project05_VPC.id
  cidr_block = "172.31.96.0/20"

  tags = {
    Name = "private_03"
  }
}

resource "aws_subnet" "private_04" {
  vpc_id     = aws_default_vpc.project05_VPC.id
  cidr_block = "172.31.112.0/20"

  tags = {
    Name = "private_04"
  }
}

resource "aws_lb_target_group" "project-05-lb-target" {
  name        = "project-05-lb-target"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_default_vpc.project05_VPC.id
}

resource "aws_autoscaling_attachment" "project05-as-attachment" {
  autoscaling_group_name = aws_autoscaling_group.project-05-was-scale-group.id
  lb_target_group_arn    = aws_lb_target_group.project-05-lb-target.arn
}

resource "aws_launch_configuration" "project-05-was-launch" {
  name_prefix     = "was-launch-config"
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.was_sg.id]
}

resource "aws_autoscaling_group" "project-05-was-scale-group" {
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.project-05-was-launch.id
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

resource "aws_internet_gateway" "project05_VPC_gateway" {
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_default_network_acl" "project05_VPC_netacl" {
  default_network_acl_id = aws_default_vpc.project05_VPC.default_network_acl_id
  subnet_ids = [
    aws_default_subnet.public_01.id,
    aws_default_subnet.public_02.id,
    aws_default_subnet.public_03.id,
    aws_default_subnet.public_04.id,
  ]

  ingress {
    rule_no    = 100
    protocol   = -1
    action     = "allow"
    to_port    = 0
    from_port  = 0
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = -1
    action     = "allow"
    to_port    = 0
    from_port  = 0
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_default_security_group" "project05_VPC_security" {
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# alb-sg
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

# was-sg
resource "aws_security_group" "was_sg" {
  name        = "was_sg"
  description = "WAS security group"
  vpc_id      = aws_default_vpc.project05_VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.alb-sg.id] # alb로 들어온 트래픽만 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "was_sg"
  }
}

# RDS-sg
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "RDS security group for PostgreSQL"
  vpc_id      = aws_default_vpc.project05_VPC.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds-sg"
  }
}

# RDS-subnet-group
resource "aws_db_subnet_group" "rds_sub_group" {
  name = "rds-sub-group"
  subnet_ids = [
    aws_subnet.private_03.id,
    aws_subnet.private_04.id
  ]

  tags = {
    Name = "rds-sub-group"
  }
}

# EIP
# resource "aws_eip" "lb" {
#   domain   = "vpc"
#   instance = aws_instance.bastion_ec2.id
# }

# Bastion-host-ec2-sg
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["211.34.202.2"] # 용산 SeSAC IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion-sg"
  }
}

# NAT-sg
resource "aws_security_group" "nat_sg" {
  name   = "nat-sg"
  vpc_id = aws_default_vpc.project05_VPC.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "nat-sg"
  }
}

# k8s-sg
resource "aws_security_group" "k8s-sg" {
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_instance.bastion_ec2.id] # Bastion Host에서만 접근
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.project05_VPC.id] # 내부에서만 접근
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.project05_VPC.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_route_table" "project05_VPC_public_route_table" {
  default_route_table_id = aws_default_vpc.project05_VPC.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project05_VPC_gateway.id
  }

  tags = {
    Name = "project05_VPC_public_gateway"
  }
}

resource "aws_route_table_association" "public_01_connect" {
  subnet_id      = aws_default_subnet.public_01.id
  route_table_id = aws_default_route_table.project05_VPC_public_route_table.id
}

resource "aws_route_table_association" "public_02_connect" {
  subnet_id      = aws_default_subnet.public_02.id
  route_table_id = aws_default_route_table.project05_VPC_public_route_table.id
}

resource "aws_route_table_association" "public_03_connect" {
  subnet_id      = aws_default_subnet.public_03.id
  route_table_id = aws_default_route_table.project05_VPC_public_route_table.id
}

resource "aws_route_table_association" "public_04_connect" {
  subnet_id      = aws_default_subnet.public_04.id
  route_table_id = aws_default_route_table.project05_VPC_public_route_table.id
}

resource "aws_route_table" "project05_VPC_private_route_table" {
  vpc_id = aws_default_vpc.project05_VPC.id

  route {
    cidr_block = "172.31.0.0/20"
  }

  tags = {
    Name = "project05_VPC_private_gateway"
  }
}

resource "aws_route_table_association" "private_01_connect" {
  subnet_id      = aws_subnet.private_01.id
  route_table_id = aws_route_table.project05_VPC_private_route_table.id
}

resource "aws_route_table_association" "private_02_connect" {
  subnet_id      = aws_subnet.private_02.id
  route_table_id = aws_route_table.project05_VPC_private_route_table.id
}

resource "aws_route_table_association" "private_03_connect" {
  subnet_id      = aws_subnet.private_03.id
  route_table_id = aws_route_table.project05_VPC_private_route_table.id
}

resource "aws_route_table_association" "private_04_connect" {
  subnet_id      = aws_subnet.private_04.id
  route_table_id = aws_route_table.project05_VPC_private_route_table.id
}
