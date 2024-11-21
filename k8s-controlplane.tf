resource "tls_private_key" "k8s_control_plane" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "k8s_control_plane" {
  key_name   = "k8s_control_plane"
  public_key = tls_private_key.k8s_control_plane.public_key_openssh
}

output "k8s_control_plane_ssh_private_key" {
  value     = tls_private_key.k8s_control_plane.private_key_openssh
  sensitive = true
}

resource "aws_instance" "k8s_control_plane_01" {
  ami                         = var.ami_id
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.k8s_control_plane.key_name
  subnet_id                   = aws_subnet.private_k8s_01.id
  disable_api_stop            = false
  disable_api_termination     = true
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.common_kubernetes_profile.name
  vpc_security_group_ids = [
    aws_security_group.k8s_control_plane_server.id,
    aws_security_group.k8s_control_plane_client.id,
    aws_security_group.ssh_server.id,
    aws_security_group.kubectl_instance.id,
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
  depends_on = [
    aws_subnet.private_k8s_01
  ]
}

resource "aws_instance" "k8s_control_plane_02" {
  ami                         = var.ami_id
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.k8s_control_plane.key_name
  subnet_id                   = aws_subnet.private_k8s_02.id
  disable_api_stop            = false
  disable_api_termination     = true
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.common_kubernetes_profile.name
  vpc_security_group_ids = [
    aws_security_group.k8s_control_plane_server.id,
    aws_security_group.k8s_control_plane_client.id,
    aws_security_group.ssh_server.id,
    aws_security_group.kubectl_instance.id,
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
  depends_on = [
    aws_subnet.private_k8s_02
  ]
}

resource "aws_instance" "k8s_control_plane_03" {
  ami                         = var.ami_id
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.k8s_control_plane.key_name
  subnet_id                   = aws_subnet.private_k8s_03.id
  disable_api_stop            = false
  disable_api_termination     = true
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.common_kubernetes_profile.name
  vpc_security_group_ids = [
    aws_security_group.k8s_control_plane_server.id,
    aws_security_group.k8s_control_plane_client.id,
    aws_security_group.ssh_server.id,
    aws_security_group.kubectl_instance.id,
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
  depends_on = [
    aws_subnet.private_k8s_03
  ]
}

resource "aws_security_group" "k8s_control_plane_client" {
  name   = "k8s_control_plane_client"
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_security_group" "k8s_control_plane_server" {
  name   = "k8s_control_plane_server"
  vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_security_group_rule" "k8s_control_plane_server_etcd_client" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_etcd_peer" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 2380
  to_port                  = 2380
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_k8s_api" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_kubelet_api" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_kube-scheduler" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 10257
  to_port                  = 10257
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_kube-controller-manager" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 10259
  to_port                  = 10259
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_calico_bgp" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 179
  to_port                  = 179
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_calico_vxlan" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 4789
  to_port                  = 4789
  protocol                 = "udp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_calico_typha" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 5473
  to_port                  = 5473
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_node_exporter" {
  security_group_id        = aws_security_group.k8s_control_plane_server.id
  source_security_group_id = aws_security_group.k8s_control_plane_client.id
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "k8s_control_plane_server_out" {
  security_group_id = aws_security_group.k8s_control_plane_server.id
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "-1"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  ipv6_cidr_blocks = [
    "::/0"
  ]
}

resource "aws_security_group" "kubectl_instance" {
  vpc_id = aws_default_vpc.project05_VPC.id
  name   = "kubectl_instance"
}

resource "aws_security_group_rule" "kubectl_in" {
  security_group_id        = aws_security_group.kubectl_instance.id
  source_security_group_id = aws_security_group.kubectl_lb.id
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "kubectl_out" {
  security_group_id = aws_security_group.kubectl_instance.id
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "-1"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
