data "aws_route53_zone" "public_domain" {
  name = "${var.public_domain}."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.public_domain.zone_id
  name    = "www.${var.public_domain}"
  type    = "A"
  ttl     = 60

  records = aws_instance.web.*.public_ip
}
