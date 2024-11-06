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
}

resource "aws_subnet" "private_02" {
    vpc_id = aws_default_vpc.project05_VPC.id
    cidr_block = "172.31.80.0/20"
}

resource "aws_subnet" "private_03" {
    vpc_id = aws_default_vpc.project05_VPC.id
    cidr_block = "172.31.96.0/20"
}

resource "aws_subnet" "private_04" {
    vpc_id = aws_default_vpc.project05_VPC.id
    cidr_block = "172.31.112.0/20"
}

resource "aws_lb_target_group" "project-05-lb-target" {
    name = "project-05-lb-target"
    target_type = "alb"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_default_vpc.project05_VPC.id
}

resource "aws_autoscaling_attachment" "project05-as-attachment" {
    autoscaling_group_name = aws_autoscaling_group.project-05-was-scale-group.id
    lb_target_group_arn = aws_lb_target_group.project-05-lb-target.arn
}

resource "aws_autoscaling_group" "project-05-was-scale-group" {
    min_size = 2
    max_size = 4
    desired_capacity = 2
    launch_configuration = [aws_instance.was01, aws_instance.was02]
    vpc_zone_identifier = [aws_default_subnet.public_01, aws_default_subnet.public_02, aws_default_subnet.public_03, aws_default_subnet.public_04]
}

resource "aws_lb" "project-05-kube-lb" {
    name = "project-05-kube-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [project05_VPC_security.id]
    subnets = [aws_default_subnet.public_01, aws_default_subnet.public_02, aws_default_subnet.public_03, aws_default_subnet.public_04]
}

resource "aws_lb_listener" "project05-lb-ln" {
    load_balancer_arn = aws_lb.project-05-kube-lb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.project-05-lb-target.arn
    }
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
