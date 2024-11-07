resource "aws_route_table" "rds_route_table" {
  vpc_id = aws_default_vpc.project05_VPC.id
  tags = {
    "Name" = "rds private table"
  }
}

resource "aws_subnet" "rds_private_1" {
  vpc_id            = aws_default_vpc.project05_VPC.id
  cidr_block        = "172.31.128.0/20"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "rds private 1"
  }
}

resource "aws_subnet" "rds_private_2" {
  vpc_id            = aws_default_vpc.project05_VPC.id
  cidr_block        = "172.31.144.0/20"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "rds private 2"
  }
}

resource "aws_subnet" "rds_private_3" {
  vpc_id            = aws_default_vpc.project05_VPC.id
  cidr_block        = "172.31.160.0/20"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "rds private 3"
  }
}

resource "aws_subnet" "rds_private_4" {
  vpc_id            = aws_default_vpc.project05_VPC.id
  cidr_block        = "172.31.176.0/20"
  availability_zone = "ap-northeast-2d"
  tags = {
    Name = "rds private 4"
  }
}

resource "aws_route_table_association" "rds_private_1" {
  route_table_id = aws_route_table.rds_route_table.id
  subnet_id      = aws_subnet.rds_private_1.id
}

resource "aws_route_table_association" "rds_private_2" {
  route_table_id = aws_route_table.rds_route_table.id
  subnet_id      = aws_subnet.rds_private_2.id
}

resource "aws_route_table_association" "rds_private_3" {
  route_table_id = aws_route_table.rds_route_table.id
  subnet_id      = aws_subnet.rds_private_3.id
}

resource "aws_route_table_association" "rds_private_4" {
  route_table_id = aws_route_table.rds_route_table.id
  subnet_id      = aws_subnet.rds_private_4.id
}

resource "aws_db_subnet_group" "rds_private_subnets" {
  name = "rds_private_subnets"
  subnet_ids = [
    aws_subnet.rds_private_1.id,
    aws_subnet.rds_private_2.id,
    aws_subnet.rds_private_3.id,
    aws_subnet.rds_private_4.id,
  ]
}

# rds_server에 접속 해야 하는 인스턴스에 적용할 보안 그룹입니다.
resource "aws_security_group" "rds_client" {
  name        = "rds_client"
  description = "Only instances with this security group can connect to the rds server."
  vpc_id      = aws_default_vpc.project05_VPC.id
  lifecycle {
    create_before_destroy = true
  }
}

# rds_client 보안그룹을 가진 인스턴스만 접근을 허용합니다.
resource "aws_security_group" "rds_server" {
  name        = "rds_server"
  description = "Only instances with a security group called rds_client are allowed access."
  vpc_id      = aws_default_vpc.project05_VPC.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_server_in" {
  security_group_id        = aws_security_group.rds_server.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_client.id
}

resource "aws_security_group_rule" "rds_server_out" {
  security_group_id = aws_security_group.rds_server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
}

resource "aws_db_parameter_group" "rds_postgres" {
  name   = "rds postgres"
  family = "postgres16"
  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_instance" "rds_instance" {
  skip_final_snapshot  = true
  allocated_storage    = 128
  storage_type         = "gp3"
  identifier           = ""
  db_subnet_group_name = aws_db_subnet_group.rds_private_subnets.name
  publicly_accessible  = false
  engine               = "postgres"
  engine_version       = "16.4"
  instance_class       = "db.t4g.micro"
  db_name              = ""
  username             = var.db_username
  password             = var.db_password
  ca_cert_identifier   = "rds-ca-rsa-2048-g1"
  parameter_group_name = aws_db_parameter_group.rds_postgres.name
}
