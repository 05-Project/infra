resource "aws_s3_bucket" "log_store" {
  bucket = "log-store-392b-4cf3-af98"
  tags = {
    Name = "log-store"
  }
}

# S3 버킷 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "log_store" {
  bucket = aws_s3_bucket.log_store.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACL 전부 차단
resource "aws_s3_bucket_public_access_block" "log_store" {
  bucket                  = aws_s3_bucket.log_store.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "log_store" {
  bucket = aws_s3_bucket.log_store.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
