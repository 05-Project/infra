resource "tls_private_key" "k8s_node" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "k8s_node" {
  key_name   = "k8s_node"
  public_key = tls_private_key.k8s_node.public_key_openssh
}

output "k8s_node_ssh_private_key" {
  value     = tls_private_key.k8s_node.private_key_openssh
  sensitive = true
}

resource "aws_instance" "k8s_node_01" {
  ami                         = var.ami_id
  instance_type               = "t3.xlarge"
  key_name                    = aws_key_pair.k8s_node.key_name
  subnet_id                   = aws_subnet.private_k8s_01.id
  disable_api_stop            = false
  disable_api_termination     = true
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.node_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.k8s_node_server.id,
    aws_security_group.k8s_node_client.id,
    aws_security_group.k8s_control_plane_client.id,
    aws_security_group.ssh_server.id,
  ]
  root_block_device {
    volume_size = 32
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "node-01"
  }
  depends_on = [
    aws_subnet.private_k8s_01
  ]
}

resource "aws_instance" "k8s_node_02" {
  ami                         = var.ami_id
  instance_type               = "t3.xlarge"
  key_name                    = aws_key_pair.k8s_node.key_name
  subnet_id                   = aws_subnet.private_k8s_02.id
  disable_api_stop            = false
  disable_api_termination     = true
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.node_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.k8s_node_server.id,
    aws_security_group.k8s_node_client.id,
    aws_security_group.k8s_control_plane_client.id,
    aws_security_group.ssh_server.id,
  ]
  root_block_device {
    volume_size = 32
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "node-02"
  }
  depends_on = [
    aws_subnet.private_k8s_02
  ]
}

resource "aws_instance" "k8s_node_03" {
  ami                         = var.ami_id
  instance_type               = "t3.xlarge"
  key_name                    = aws_key_pair.k8s_node.key_name
  subnet_id                   = aws_subnet.private_k8s_03.id
  disable_api_stop            = false
  disable_api_termination     = true
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.node_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.k8s_node_server.id,
    aws_security_group.k8s_node_client.id,
    aws_security_group.k8s_control_plane_client.id,
    aws_security_group.ssh_server.id,
  ]
  root_block_device {
    volume_size = 32
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "node-03"
  }
  depends_on = [
    aws_subnet.private_k8s_03
  ]
}

resource "aws_security_group" "k8s_node_client" {
  name   = "k8s_node_client"
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_security_group" "k8s_node_server" {
  name   = "k8s_node_server"
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_security_group_rule" "k8s_node_server_kubelet_api" {
  security_group_id        = aws_security_group.k8s_node_server.id
  source_security_group_id = aws_security_group.k8s_node_client.id
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_node_server_nodeports" {
  security_group_id        = aws_security_group.k8s_node_server.id
  source_security_group_id = aws_security_group.k8s_node_client.id
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_node_server_node_exporter" {
  security_group_id        = aws_security_group.k8s_node_server.id
  source_security_group_id = aws_security_group.k8s_node_client.id
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_node_server_out" {
  security_group_id        = aws_security_group.k8s_node_server.id
  source_security_group_id = aws_security_group.k8s_node_client.id
  type                     = "egress"
  from_port                = -1
  to_port                  = -1
  protocol                 = -1
}