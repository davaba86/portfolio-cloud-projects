module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.acm
  }

  domain_name = var.public_domain
  zone_id     = data.aws_route53_zone.selected.id

  subject_alternative_names = [
    "*.${var.public_domain}",
    "www.${var.public_domain}",
  ]

  create_route53_records  = false
  validation_record_fqdns = module.route53_records.validation_route53_record_fqdns

  tags = {
    Name = var.public_domain
  }
}
