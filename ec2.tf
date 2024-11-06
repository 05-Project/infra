variable "key_pair" {
  type    = string
  default = "ec2-05-key"
}

resource "aws_ami_from_instance" "whoami" {
  name               = "whoami"
  source_instance_id = "ami-02c329a4b4aba6a48"
}

# WAS01-ec2
resource "aws_instance" "was01" {
  ami           = aws_ami_from_instance.whoami.name
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_subnet.private_01.id
    device_index         = 0
  }

  tags = {
    Name = "WAS01"
  }
}

# WAS02-ec2
resource "aws_instance" "was02" {
  ami           = aws_ami_from_instance.whoami.name
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_subnet.private_02.id
    device_index         = 0
  }

  tags = {
    Name = "WAS02"
  }
}

# Bastion-ec2
resource "aws_instance" "bastion_ec2" {
  ami                         = aws_ami_from_instance.whoami.name
  instance_type               = "t2.micro"
  associate_public_ip_address = true # 공인 IP 설정
  subnet_id                   = aws_default_subnet.public_01.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.key_pair
  tags                        = { Name = "bastion-ec2" }
}

# NAT-ec2
resource "aws_instance" "nat_ec2" {
  ami                         = aws_ami_from_instance.whoami.name
  instance_type               = "t2.micro"
  associate_public_ip_address = true # 공인 IP 설정
  subnet_id                   = aws_default_subnet.public_02.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  source_dest_check           = false # 다른 인스턴스의 트래픽을 중계하도록 허용
  key_name                    = var.key_pair
  tags                        = { Name = "nat-ec2" }
}

resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "p@ssword"
  skip_final_snapshot    = true  # 삭제시 스냅샷 건너뛰기
  publicly_accessible    = false # 퍼블릭 접근 허용 여부
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_sub_group.name
  tags = {
    Name = "rds"
  }
}

