# NAT-ec2
resource "aws_instance" "nat_ec2" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true # 공인 IP 설정
  subnet_id                   = aws_default_subnet.public_02.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  source_dest_check           = false # 다른 인스턴스의 트래픽을 중계하도록 허용
  key_name                    = var.key_pair

  tags = {
    Name = "nat-ec2"
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
