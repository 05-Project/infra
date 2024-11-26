resource "aws_route53_zone" "domain_05_project" {
  name = "05-project.narumir.io"
}

resource "aws_route53_record" "github_verify_05_project" {
  zone_id = aws_route53_zone.domain_05_project.zone_id
  name    = "_gh-05-Project-o"
  type    = "TXT"
  ttl     = 300
  records = [
    "e3c8196057"
  ]
}

resource "aws_route53_record" "www_cname" {
  zone_id = aws_route53_zone.domain_05_project.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = [
    aws_lb.k8s_external_lb.dns_name,
  ]
}

resource "aws_route53_record" "argocd_cname" {
  zone_id = aws_route53_zone.domain_05_project.zone_id
  name    = "argocd"
  type    = "CNAME"
  ttl     = 300
  records = [
    aws_lb.k8s_external_lb.dns_name,
  ]
}
