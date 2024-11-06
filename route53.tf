resource "aws_route53_zone" "domain_05_project" {
  name = "05-project.narumir.io"
}

resource "aws_route53_record" "github_verify_05_project" {
  zone_id = aws_route53_zone.domain_05_project.zone_id
  name    = "_gh-05-Project-o.05-project"
  type    = "TXT"
  ttl     = 300
  records = [
    "0368746b4a"
  ]
}
