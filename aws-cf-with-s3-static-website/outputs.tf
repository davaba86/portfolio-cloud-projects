output "website_s3_domain" {
  value = aws_s3_bucket_website_configuration.cf_origin.website_domain
}

output "website_s3_endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.cf_origin.website_endpoint}"
}

output "website_alias" {
  value = "https://${aws_route53_record.www.name}"
}
