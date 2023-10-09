data "http" "my_pub_addr" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_pub_addr_cleansed = "${chomp(data.http.my_pub_addr.response_body)}/32"
}

module "sg_web" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.env_name_short}-sg-web"
  description = "Allow filtered inbound traffic to web"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    for item in var.sg_web_ingress : {
      from_port   = item.dst_port
      to_port     = item.dst_port
      protocol    = item.protocol
      description = item.description
      cidr_blocks = local.my_pub_addr_cleansed
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
