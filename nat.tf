resource "tls_private_key" "nat_instance" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "nat_instance" {
  key_name   = "nat_instance"
  public_key = tls_private_key.nat_instance.public_key_openssh
}

output "nat_instance_ssh_private_key" {
  value     = tls_private_key.nat_instance.private_key_openssh
  sensitive = true
}

# NAT-ec2
resource "aws_instance" "nat_instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.nat_instance.key_name
  subnet_id                   = aws_default_subnet.public_01.id
  disable_api_stop            = false
  disable_api_termination     = false
  associate_public_ip_address = true  # 공인 IP 설정
  source_dest_check           = false # 다른 인스턴스의 트래픽을 중계하도록 허용
  root_block_device {
    volume_size = 32
  }
  metadata_options {
    http_tokens = "required"
  }
  vpc_security_group_ids = [
    aws_security_group.ssh_server.id,
    aws_security_group.nat_instance.id,
  ]
  tags = {
    Name = "nat-instance"
  }
}

resource "aws_security_group" "nat_instance" {
  vpc_id = aws_default_vpc.project05_VPC.id
  name   = "nat-instance"
}

resource "aws_security_group_rule" "nat_instance_in" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks = [
    aws_default_vpc.project05_VPC.cidr_block,
  ]
}

resource "aws_security_group_rule" "nat_instance_out" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
