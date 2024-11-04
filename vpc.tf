resource "aws_default_vpc" "default"{
    tags = {
        Name = "default"
    }
}

resource "aws_default_subnet" "first"{ 
    availability_zone = "ap-northeast-2a"

    tags = {
        Name = "first"
    }
}

resource "aws_default_subnet" "second"{ 
    availability_zone = "ap-northeast-2b"

    tags = {
        Name = "second"
    }
}

resource "aws_default_subnet" "third"{ 
    availability_zone = "ap-northeast-2c"

    tags = {
        Name = "third"
    }
}

resource "aws_default_subnet" "fourth"{ 
    availability_zone = "ap-northeast-2d"

    tags = {
        Name = "fourth"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_default_vpc.default.id
}

resource "aws_default_network_acl" "netacl" {
    default_network_acl_id = aws_default_vpc.default.default_network_acl_id
    subnet_ids = [
        aws_default_subnet.first.id,
        aws_default_subnet.second.id,
        aws_default_subnet.third.id,
        aws_default_subnet.fourth.id,
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

resource "aws_default_security_group" "secur" {
    vpc_id = aws_default_vpc.default.id

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

resource "aws_default_route_table" "rt" {
    default_route_table_id = aws_default_vpc.default.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "rt"
    }
}

resource "aws_route_table_association" "first" {
    subnet_id      = aws_default_subnet.first.id
    route_table_id = aws_default_route_table.rt.id
}

resource "aws_route_table_association" "second" {
    subnet_id      = aws_default_subnet.second.id
    route_table_id = aws_default_route_table.rt.id
}

resource "aws_route_table_association" "third" {
    subnet_id      = aws_default_subnet.third.id
    route_table_id = aws_default_route_table.rt.id
}

resource "aws_route_table_association" "fourth" {
    subnet_id      = aws_default_subnet.fourth.id
    route_table_id = aws_default_route_table.rt.id
}