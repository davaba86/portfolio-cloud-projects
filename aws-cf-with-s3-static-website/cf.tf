resource "random_password" "cf_custom_header_password" {
  length  = 16
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "aws_cloudfront_distribution" "website" {

  enabled         = true
  is_ipv6_enabled = true

  origin {
    origin_id   = aws_s3_bucket_website_configuration.cf_origin.website_endpoint
    domain_name = aws_s3_bucket_website_configuration.cf_origin.website_endpoint

    custom_header {
      name  = "Referer"
      value = random_password.cf_custom_header_password.result
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = ["www.mechaconsulting.org"]

  default_cache_behavior {

    target_origin_id = aws_s3_bucket_website_configuration.cf_origin.website_endpoint

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = module.acm.acm_certificate_arn
    ssl_support_method             = "sni-only"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  price_class = "PriceClass_100"

}
