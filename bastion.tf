# Bastion-ec2
resource "aws_instance" "bastion_ec2" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true # 공인 IP 설정
  subnet_id                   = aws_default_subnet.public_01.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.key_pair
  tags = {
    Name = "bastion-ec2"
  }
}

# Bastion-host-ec2-sg
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20"]
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

# EIP
# resource "aws_eip" "lb" {
#   domain   = "vpc"
#   instance = aws_instance.bastion_ec2.id
# }