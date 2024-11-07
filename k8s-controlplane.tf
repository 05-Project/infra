resource "tls_private_key" "k8s_control_plane" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "k8s_control_plane" {
  key_name   = "k8s_control_plane"
  public_key = tls_private_key.k8s_control_plane.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.k8s_control_plane.private_key_pem}' > ./k8s_control.pem"
  }
}

resource "aws_instance" "k8s_control_plane_01" {
  ami                         = var.ami_id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.k8s_control_plane.key_name
  subnet_id                   = aws_subnet.private_01.id
  # 중요한 인스턴스임으로 임의로 삭제하는 것을 방지
  disable_api_stop            = true
  disable_api_termination     = true
  associate_public_ip_address = false
  security_groups = [
    aws_security_group.k8s-sg
  ]
  root_block_device {
    volume_size = 32
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "control-plane-01"
  }
}

resource "aws_instance" "k8s_control_plane_02" {
  ami                         = var.ami_id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.k8s_control_plane.key_name
  subnet_id                   = aws_subnet.private_02.id
  disable_api_stop            = true
  disable_api_termination     = true
  associate_public_ip_address = false
  security_groups = [
    aws_security_group.k8s-sg
  ]
  root_block_device {
    volume_size = 32
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "control-plane-02"
  }
}

resource "aws_instance" "k8s_control_plane_03" {
  ami                         = var.ami_id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.k8s_control_plane.key_name
  subnet_id                   = aws_subnet.private_03.id
  disable_api_stop            = true
  disable_api_termination     = true
  associate_public_ip_address = false
  security_groups = [
    aws_security_group.k8s-sg
  ]
  root_block_device {
    volume_size = 32
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "control-plane-03"
  }
}
