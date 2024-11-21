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

resource "aws_s3_bucket_cors_configuration" "media_storage" {
  bucket = aws_s3_bucket.media_storage.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 300
  }
}

data "aws_iam_policy_document" "cdn_cloudfront_access_s3" {
  statement {
    sid       = "AllowCloudFrontServicePrincipalReadWrite"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.media_storage.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.cdn.arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "media_storage" {
  bucket = aws_s3_bucket.media_storage.id
  policy = data.aws_iam_policy_document.cdn_cloudfront_access_s3.json
}
