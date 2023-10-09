output "acme_certificate_url" {
  value = acme_certificate.certificate.certificate_url
}

output "wordpress_url" {
  value = "https://${aws_route53_record.www.fqdn}"
}
