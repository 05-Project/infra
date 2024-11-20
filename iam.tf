# S3 허용 접근 정책 생성
resource "aws_iam_policy" "k8s_allow_access" {
  name = "k8s_allow_access"
  policy = data.aws_iam_policy_document.k8s_allow_access.json
}

data "aws_iam_policy_document" "k8s_allow_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
      ]
    resources = [
      aws_s3_bucket.media_storage.arn,
      "${aws_s3_bucket.media_storage.arn}/*"
    ]
  }
}

# Role에 정책을 추가
resource "aws_iam_role_policy_attachment" "attach_media_access_policy" {
  role = aws_iam_role.k8s_access_role.name
  policy_arn = aws_iam_policy.k8s_allow_access.arn
}

# Node에 적용할 Instance Profile 생성
resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "node_instance_profile"
  role = aws_iam_role.k8s_access_role.name
}
