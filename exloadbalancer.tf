resource "aws_lb" "project05-nodetarget-lb" {
  name               = "project05-nodetarget-lb"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.private_k8s_01.id,
    aws_subnet.private_k8s_02.id,
    aws_subnet.private_k8s_03.id
  ]
  tags = {
    Name = "project05-nodetarget-lb"
  }
}

resource "aws_lb_target_group" "project05-alb-target" {
  name        = "project05-alb-target"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.project05_VPC.id

  tags = {
    Name = "project05-alb-target"
  }
}

resource "aws_lb_listener" "node-ln" {
  load_balancer_arn = aws_lb.project05-nodetarget-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project05-alb-target.arn
  }
}

resource "aws_lb_target_group_attachment" "project05-attach-node01" {
  target_group_arn = aws_lb_target_group.project05-alb-target.arn
  target_id        = aws_instance.k8s_node_01.private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "project05-attach-node02" {
  target_group_arn = aws_lb_target_group.project05-alb-target.arn
  target_id        = aws_instance.k8s_node_02.private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "project05-attach-node03" {
  target_group_arn = aws_lb_target_group.project05-alb-target.arn
  target_id        = aws_instance.k8s_node_03.private_ip
  port             = 80
}

# // 1. ALB 를 위한 IAM 역할, 정책 설정
# provider "aws" {
#   region = "ap-northeast-2"
# }

# resource "aws_iam_role" "alb_role" {
#   name = "alb-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "[elasticloadbalancing.amazonaws.com](http://elasticloadbalancing.amazonaws.com/)"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "alb_policy" {
#   name = "alb-policy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:DescribeInstances",
#           "ec2:DescribeTags",
#           "elasticloadbalancing:DescribeLoadBalancers",
#           "elasticloadbalancing:DescribeListeners",
#           "elasticloadbalancing:DescribeRules",
#           "elasticloadbalancing:DescribeTargetGroups",
#           "elasticloadbalancing:DescribeTargetHealth",
#           "elasticloadbalancing:RegisterTargets",
#           "elasticloadbalancing:DeregisterTargets"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_alb_policy" {
#   role       = aws_iam_role.alb_role.name
#   policy_arn = aws_iam_policy.alb_policy.arn
# }

# // 2. Ingress Controller 를 위한 IAM 역할, 정책설정
# resource "aws_iam_role" "ingress_controller_role" {
#   name = "ingress-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "[eks.amazonaws.com](http://eks.amazonaws.com/)"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "ingress_controller_policy" {
#   name = "ingress-controller-policy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:DescribeLoadBalancers",
#           "elasticloadbalancing:DescribeListeners",
#           "elasticloadbalancing:DescribeRules",
#           "elasticloadbalancing:DescribeTargetGroups",
#           "elasticloadbalancing:DescribeTargetHealth",
#           "elasticloadbalancing:RegisterTargets",
#           "elasticloadbalancing:DeregisterTargets"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_ingress_controller_policy" {
#   role       = aws_iam_role.ingress_controller_role.name
#   policy_arn = aws_iam_policy.ingress_controller_policy.arn
# }

# // 3. 쿠버네티스에서 IAM 역할 사용
# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }

# resource "kubernetes_service_account" "ingress_controller" {
#   metadata {
#     name      = "nginx-ingress-service-account"
#     namespace = "kube-system"
#     annotations = {
#       "[eks.amazonaws.com/role-arn](http://eks.amazonaws.com/role-arn)" = aws_iam_role.ingress_controller_role.arn
#     }
#   }
# }

