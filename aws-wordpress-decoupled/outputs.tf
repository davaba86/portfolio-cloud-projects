output "wordpress_url" {
  value = "https://${aws_route53_record.www.fqdn}"
}

output "compute_node_ids" {
  value = aws_instance.web.*.id
}

output "rds_public_endpoint" {
  value = aws_db_instance.wordpress.address
}
