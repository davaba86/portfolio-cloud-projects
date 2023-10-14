data "aws_route53_zone" "selected" {
  name = "${var.public_domain}."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${var.public_domain}"
  type    = "CNAME"
  ttl     = 300

  records = [aws_cloudfront_distribution.website.domain_name]
}

module "route53_records" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.route53
  }

  create_certificate          = false
  create_route53_records_only = true

  distinct_domain_names = module.acm.distinct_domain_names
  zone_id               = data.aws_route53_zone.selected.id

  acm_certificate_domain_validation_options = module.acm.acm_certificate_domain_validation_options

  tags = {
    Name = var.public_domain
  }
}
