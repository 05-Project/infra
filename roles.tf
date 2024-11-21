# 쿠버 공통 Role : 컨트롤 노드와 워커 노드에서 사용하는 Role
resource "aws_iam_role" "common_kubernetes_role" {
  name = "CommonKubernetesRole"

  # EC2가 Role을 사용할 수 있도록 Trust Policy 추가
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}




# 정책 Attach: 공통 Kubernetes Role (컨트롤/워커 노드)
resource "aws_iam_role_policy_attachment" "common_s3_attachment" {
  role       = aws_iam_role.common_kubernetes_role.name
  policy_arn = aws_iam_policy.s3_rw_policy.arn
}

resource "aws_iam_role_policy_attachment" "common_ebs_attachment" {
  role       = aws_iam_role.common_kubernetes_role.name
  policy_arn = aws_iam_policy.ebs_rw_policy.arn
}

resource "aws_iam_role_policy_attachment" "common_alb_attachment" {
  role       = aws_iam_role.common_kubernetes_role.name
  policy_arn = aws_iam_policy.alb_policy.arn
}

resource "aws_iam_role_policy_attachment" "common_ingress_controller_attachment" {
  role       = aws_iam_role.common_kubernetes_role.name
  policy_arn = aws_iam_policy.ingress_controller_policy.arn
}

resource "aws_iam_role_policy_attachment" "common_ebs_csi_attachment" {
  role       = aws_iam_role.common_kubernetes_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}







# Instance Profiles 생성
resource "aws_iam_instance_profile" "common_kubernetes_profile" {
  name = "CommonKubernetesProfile"
  role = aws_iam_role.common_kubernetes_role.name
}
