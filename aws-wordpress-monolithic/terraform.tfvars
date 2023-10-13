project_name = "WordPress Monolithic"
owner        = "David Abarca"

env_name_long  = "Development"
env_name_short = "dev"

region_code_execution = "eu-west-1"
aws_regions = {
  "eu-west-1" = "ireland"
}

vpc_cidr                 = "172.16.0.0/16"
vpc_azs                  = ["eu-west-1a", "eu-west-1b"]
vpc_subnet_public_range  = ["172.16.101.0/24", "172.16.102.0/24"]
vpc_subnet_private_range = ["172.16.1.0/24", "172.16.2.0/24"]

public_domain = "mechaconsulting.org"

sg_web_ingress = {
  "ssh" = {
    "dst_port"    = "22",
    "protocol"    = "tcp",
    "description" = "SSH from WMI"
  },
  "http" = {
    "dst_port"    = "80",
    "protocol"    = "tcp",
    "description" = "HTTP from WMI"
  },
  "https" = {
    "dst_port"    = "443",
    "protocol"    = "tcp",
    "description" = "HTTPS from WMI"
  },
  "ping" = {
    "dst_port"    = "-1",
    "protocol"    = "icmp",
    "description" = "ICMP from WMI"
  }
}

disable_acme_tls_prod = true
