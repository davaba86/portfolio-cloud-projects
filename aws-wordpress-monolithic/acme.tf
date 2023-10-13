locals {
  acme_url_portion = var.disable_acme_tls_prod ? "acme-staging-v02" : "acme-v02"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "david.abarca@mechaconsulting.org"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = data.aws_route53_zone.public_domain.name
  subject_alternative_names = ["*.${data.aws_route53_zone.public_domain.name}"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.public_domain.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}

resource "local_file" "certificate_pem" {
  content  = acme_certificate.certificate.certificate_pem
  filename = "${var.public_domain}.pem"
}

resource "local_file" "private_key_pem" {
  content  = acme_certificate.certificate.private_key_pem
  filename = "${var.public_domain}.key"
}
