output "wordpress_url" {
  value = "https://${aws_route53_record.www.fqdn}"
}

output "compute_node_ids" {
  value = aws_instance.web.*.id
}

output "rds_public_endpoint" {
  value = aws_db_instance.wordpress.address
}

output "rds_admin_user" {
  value = random_pet.rds_admin_user.id
}

output "rds_admin_password" {
  value     = random_password.rds_admin_password.result
  sensitive = true
}

output "rds_wp_db_user" {
  value = random_pet.rds_wp_db_user.id
}

output "rds_wp_db_password" {
  value     = random_password.rds_wp_db_password.result
  sensitive = true
}

