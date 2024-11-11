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
