# S3 접근 권한 정책
# 특정 S3 버킷에서 객체 읽기, 쓰기, 삭제, 버킷 목록 
resource "aws_iam_policy" "s3_rw_policy" {
  name        = "S3ReadWritePolicy"
  description = "Allows read/write access to S3"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # 객체 작업 권한 (읽기, 쓰기, 삭제)
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
        Resource = "arn:aws:s3:::media-storage-echgjtnt6hprkoe6/*"
      },
      {
        # 버킷 작업 권한 (목록 조회)
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::media-storage-echgjtnt6hprkoe6"
      }
    ]
  })
}


# EBS 접근 권한 정책
# EBS 볼륨 생성, 삭제, 연결, 분리, 설명
resource "aws_iam_policy" "ebs_rw_policy" {
  name        = "EBSReadWritePolicy"
  description = "Allows read/write access to EBS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes"
        ],
        Resource = "*"  # CSI 드라이버로 동적 프로비저닝해야해서
      }
    ]
  })
}

# ALB 관리 권한 정책
# ALB 리스너 수정, 규칙 조회 및 수정 권한
resource "aws_iam_policy" "alb_policy" {
  name        = "ALBManagementPolicy"
  description = "Allows managing ALB listeners and rules"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule"
        ],
        Resource = "*" #Kubernetes Ingress Controller 사용하면 동적생성되?서
      }
    ]
  })
}
