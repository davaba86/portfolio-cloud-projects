project_name = "AWS WordPress Decoupled"
owner        = "David Abarca"

env_name_long  = "Development"
env_name_short = "dev"

region_code_execution = "eu-west-1"
aws_regions = {
  "eu-west-1" = "ireland"
}

vpc_cidr                  = "172.16.0.0/16"
vpc_azs                   = ["eu-west-1a", "eu-west-1b"]
vpc_subnet_public_range   = ["172.16.10.0/24", "172.16.11.0/24"]
vpc_subnet_private_range  = ["172.16.20.0/24", "172.16.21.0/24"]
vpc_subnet_database_range = ["172.16.30.0/24", "172.16.31.0/24"]

public_domain = "mechaconsulting.org"

sg_alb_ingress = {
  "http" = {
    "dst_port"    = "80",
    "protocol"    = "tcp",
    "description" = "HTTP from Internet"
  },
  "https" = {
    "dst_port"    = "443",
    "protocol"    = "tcp",
    "description" = "HTTPS from Internet"
  }
}

sg_web_ingress = {
  "http" = {
    "dst_port"    = "80",
    "protocol"    = "tcp",
    "description" = "HTTP from Internet/ALB"
  },
  "https" = {
    "dst_port"    = "443",
    "protocol"    = "tcp",
    "description" = "HTTPS from Internet/ALB"
  }
}

rds_wp_db_name = "wordpress"
