resource "aws_default_vpc" "project05_VPC"{
    tags = {
        Name = "project05_VPC"
    }
}

resource "aws_default_subnet" "public_01"{ 
    availability_zone = "ap-northeast-2a"

    tags = {
        Name = "public_01"
    }
}

resource "aws_default_subnet" "public_02"{ 
    availability_zone = "ap-northeast-2b"

    tags = {
        Name = "public_02"
    }
}

resource "aws_default_subnet" "public_03"{ 
    availability_zone = "ap-northeast-2c"

    tags = {
        Name = "public_03"
    }
}

resource "aws_default_subnet" "public_04"{ 
    availability_zone = "ap-northeast-2d"

    tags = {
        Name = "public_04"
    }
}

resource "aws_subnet" "private_01" {
    vpc_id = aws_default_vpc.project05_VPC.id
    cidr_block = "172.31.64.0/20"
    tags = {Name = "private_01"}
    availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "private_02" {
    vpc_id = aws_default_vpc.project05_VPC.id
    cidr_block = "172.31.80.0/20"
    tags = {Name = "private_02"}
    availability_zone = "ap-northeast-2c"
}

resource "aws_subnet" "private_03" {
    vpc_id = aws_default_vpc.project05_VPC.id
    cidr_block = "172.31.96.0/20"
}

resource "aws_subnet" "private_04" {
    vpc_id = aws_default_vpc.project05_VPC.id
    cidr_block = "172.31.112.0/20"
}

resource "aws_internet_gateway" "project05_VPC_gateway" {
    vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_default_network_acl" "project05_VPC_netacl" {
    default_network_acl_id = aws_default_vpc.project05_VPC.default_network_acl_id
    subnet_ids = [
        aws_default_subnet.public_01.id,
        aws_default_subnet.public_02.id,
        aws_default_subnet.public_03.id,
        aws_default_subnet.public_04.id,
    ]

    ingress {
        rule_no = 100
        protocol = -1
        action = "allow"
        to_port = 0
        from_port = 0
        cidr_block = "0.0.0.0/0"
    }

    egress {
        rule_no = 100
        protocol = -1
        action = "allow"
        to_port = 0
        from_port = 0
        cidr_block = "0.0.0.0/0"
    }
}

resource "aws_default_security_group" "project05_VPC_security" {
    vpc_id = aws_default_vpc.project05_VPC.id

    ingress {
        protocol = -1
        self = true
        from_port = 0
        to_port = 0
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# RDS-sg
resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  description = "RDS security group for PostgreSQL"
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds-sg"
  }
}

# RDS-subnet-group
resource "aws_db_subnet_group" "rds_sub_group" {
  name = "rds-sub-group"
  subnet_ids = [ aws_subnet.private_01.id, aws_subnet.private_02.id ]

  tags = {
    Name = "rds-sub-group"
  }
}

# Bastion-host-ec2-sg
resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  vpc_id = aws_default_vpc.project05_VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = { Name = "bastion-sg" }
}

# NAT-sg
resource "aws_security_group" "nat_sg" {
  name = "nat-sg"
  vpc_id = aws_default_vpc.project05_VPC.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = { Name = "nat-sg" }
}

resource "aws_default_route_table" "project05_VPC_route_table" {
    default_route_table_id = aws_default_vpc.project05_VPC.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.project05_VPC_gateway.id
    }

    tags = {
        Name = "project05_VPC_gateway"
    }
}

resource "aws_route_table_association" "first" {
    subnet_id      = aws_default_subnet.public_01.id
    route_table_id = aws_default_route_table.project05_VPC_route_table.id
}

resource "aws_route_table_association" "second" {
    subnet_id      = aws_default_subnet.public_02.id
    route_table_id = aws_default_route_table.project05_VPC_route_table.id
}

resource "aws_route_table_association" "third" {
    subnet_id      = aws_default_subnet.public_03.id
    route_table_id = aws_default_route_table.project05_VPC_route_table.id
}

resource "aws_route_table_association" "fourth" {
    subnet_id      = aws_default_subnet.public_04.id
    route_table_id = aws_default_route_table.project05_VPC_route_table.id
}
