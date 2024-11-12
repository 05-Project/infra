# Worker Node Instance
resource "aws_instance" "node01" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_subnet.private_k8s_01.id
    device_index         = 0
  }

  tags = {
    Name = "node01"
  }
}

# node02-ec2
resource "aws_instance" "node02" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_subnet.private_k8s_02.id
    device_index         = 0
  }

  tags = {
    Name = "node2"
  }
}

resource "aws_instance" "node03" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_subnet.private_k8s_03.id
    device_index         = 0
  }

  tags = {
    Name = "node03"
  }
}

# S3 - node간 직접연결 없이 연결방법을 찾아야 하기 때문에 보류
# resource "aws_connect_instance_storage_config" "node01-connect-S3" {
#  instance_id   = aws_instance.node01.id
#  resource_type = "MEDIA_STREAMS"

#  storage_config {
#    s3_config {
#      bucket_name   = aws_s3_bucket.media_storage.id
#      bucket_prefix = "media_storage"
#    }
#    storage_type = "S3"
#  }
#}

# node-sg
resource "aws_security_group" "node_sg" {
  name        = "node_sg"
  description = "Node security group"
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
    Name = "node_sg"
  }
}