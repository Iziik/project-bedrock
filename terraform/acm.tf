resource "aws_acm_certificate" "ssl" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  zone_id = var.route53_zone_id
  name    = aws_acm_certificate.ssl.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.ssl.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.ssl.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "ssl_validation" {
  certificate_arn         = aws_acm_certificate.ssl.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
