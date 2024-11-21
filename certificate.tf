resource "aws_acm_certificate" "global" {
  provider          = aws.global
  domain_name       = "05-project.narumir.io"
  validation_method = "DNS"
  subject_alternative_names = [
    "*.05-project.narumir.io"
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.global.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = aws_route53_zone.domain_05_project.zone_id
  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  ttl             = 3600
  records = [
    each.value.record,
  ]
  depends_on = [
    aws_acm_certificate.global,
  ]
}

resource "aws_acm_certificate_validation" "domain_05_project" {
  provider                = aws.global
  certificate_arn         = aws_acm_certificate.global.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
  depends_on = [
    aws_route53_record.acm_validation,
  ]
}

resource "aws_acm_certificate" "seoul" {
  domain_name       = "05-project.narumir.io"
  validation_method = "DNS"
  subject_alternative_names = [
    "*.05-project.narumir.io"
  ]
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_acm_certificate_validation.domain_05_project,
  ]
}
