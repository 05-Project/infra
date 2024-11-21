resource "aws_cloudfront_origin_access_control" "cdn" {
  name                              = "cdn"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  aliases         = ["cdn.05-project.narumir.io"]
  origin {
    domain_name              = aws_s3_bucket.media_storage.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.media_storage.id
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn.id
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.media_storage.id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.global.arn
    ssl_support_method             = "sni-only"
  }
}

resource "aws_route53_record" "cdn" {
  zone_id         = aws_route53_zone.domain_05_project.zone_id
  allow_overwrite = true
  name            = "cdn.05-project.narumir.io"
  type            = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
