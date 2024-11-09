resource "aws_subnet" "private_k8s_01" {
  vpc_id            = aws_default_vpc.project05_VPC.id
  cidr_block        = "172.31.64.0/20"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "private_k8s_01"
  }
}

resource "aws_subnet" "private_k8s_02" {
  vpc_id            = aws_default_vpc.project05_VPC.id
  cidr_block        = "172.31.80.0/20"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "private_k8s_02"
  }
}

resource "aws_subnet" "private_k8s_03" {
  vpc_id            = aws_default_vpc.project05_VPC.id
  cidr_block        = "172.31.96.0/20"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "private_k8s_03"
  }
}

resource "aws_route_table" "project05_VPC_private_route_table" {
  vpc_id = aws_default_vpc.project05_VPC.id
  route {
    cidr_block = aws_default_vpc.project05_VPC.cidr_block
    gateway_id = "local"
  }
  tags = {
    Name = "project05_VPC_private_gateway"
  }
}

resource "aws_route_table_association" "private_k8s_01" {
  subnet_id      = aws_subnet.private_k8s_01.id
  route_table_id = aws_route_table.project05_VPC_private_route_table.id
}

resource "aws_route_table_association" "private_k8s_02" {
  subnet_id      = aws_subnet.private_k8s_02.id
  route_table_id = aws_route_table.project05_VPC_private_route_table.id
}

resource "aws_route_table_association" "private_k8s_03" {
  subnet_id      = aws_subnet.private_k8s_03.id
  route_table_id = aws_route_table.project05_VPC_private_route_table.id
}
