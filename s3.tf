resource "aws_s3_bucket" "media_storage" {
  bucket = "media-storage-echgjtnt6hprkoe6"
  tags = {
    Name = "media_storage"
  }
}

# S3 버킷 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "media_storage" {
  bucket = aws_s3_bucket.media_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACL 전부 차단
resource "aws_s3_bucket_public_access_block" "media_storage" {
  bucket                  = aws_s3_bucket.media_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "media_storage" {
  bucket = aws_s3_bucket.media_storage.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Node에게 미디어 파일을 빼고 넣는 등 S3에 접근할 수 있는 임시 권한(역할)을 생성
resource "aws_iam_role" "media_access_role" {
  name = "media_access_role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
}

data "aws_iam_policy_document" "node_assume_role_policy"{
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# S3 허용 접근 정책 생성
resource "aws_iam_policy" "media_allow_access_policy" {
  name = "media_allow_access_policy"
  policy = data.aws_iam_policy_document.media_allow_access_policy.json
}

data "aws_iam_policy_document" "media_allow_access_policy" {
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
  role = aws_iam_role.media_access_role.name
  policy_arn = aws_iam_policy.media_allow_access_policy.arn
}

# Node에 적용할 Instance Profile 생성
resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "node_media_instance_profile"
  role = aws_iam_role.media_access_role.name
}