module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.env_name_short
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  public_subnets  = var.vpc_subnet_public_range
  private_subnets = var.vpc_subnet_private_range

  # # If on private subnet, ensure compute node can access Internet
  # enable_nat_gateway = true

  # If on public subnet, assign public IPv4 to compute node
  map_public_ip_on_launch = true

  enable_dns_support   = true
  enable_dns_hostnames = false

  vpc_tags = {
    Name = "${var.env_name_short}-vpc-${lookup(var.aws_regions, "eu-west-1")}"
  }

  igw_tags = {
    Name = "${var.env_name_short}-igw-${lookup(var.aws_regions, "eu-west-1")}"
  }

  default_network_acl_tags = {
    Name = "${var.env_name_short}-nacl-default-${lookup(var.aws_regions, "eu-west-1")}"
  }

  default_security_group_tags = {
    Name = "${var.env_name_short}-sg-default-${lookup(var.aws_regions, "eu-west-1")}"
  }
}
