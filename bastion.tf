resource "tls_private_key" "bastion" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}

output "bastion_ssh_private_key" {
  value     = tls_private_key.bastion.private_key_openssh
  sensitive = true
}

data "aws_ssm_parameter" "bastion_allow_ips" {
  name = "/bastion/allow_ips"
}

locals {
  bastion_allow_ips = split(",", data.aws_ssm_parameter.bastion_allow_ips.value)
}

# Bastion-ec2
resource "aws_instance" "bastion_ec2" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true # 공인 IP 설정
  subnet_id                   = aws_default_subnet.public_01.id
  key_name                    = aws_key_pair.bastion.key_name
  disable_api_stop            = false
  disable_api_termination     = false
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_security_group.k8s_control_plane_client.id,
    aws_security_group.ssh_client.id,
  ]
  tags = {
    Name = "bastion-ec2"
  }
  root_block_device {
    volume_size = 8
  }
  metadata_options {
    http_tokens = "required"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_default_vpc.project05_VPC.id
  name   = "bastion"
}

resource "aws_security_group_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = local.bastion_allow_ips
}

resource "aws_security_group_rule" "bastion_out" {
  security_group_id = aws_security_group.bastion.id
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

resource "aws_security_group" "ssh_client" {
  vpc_id = aws_default_vpc.project05_VPC.id
  name   = "ssh_client"
}

resource "aws_security_group" "ssh_server" {
  vpc_id = aws_default_vpc.project05_VPC.id
  name   = "ssh_server"
}

resource "aws_security_group_rule" "ssh_server_in" {
  security_group_id        = aws_security_group.ssh_server.id
  source_security_group_id = aws_security_group.ssh_client.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "ssh_server_out" {
  security_group_id = aws_security_group.ssh_server.id
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
