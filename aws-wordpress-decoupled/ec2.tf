resource "random_pet" "rds_wp_db_user" {
  length = 1
}

resource "random_password" "rds_wp_db_password" {
  length  = 16
  special = false
}

data "template_file" "wordpress_script" {
  template = file("install_wordpress.tpl")

  vars = {
    wp_domain   = var.public_domain
    db_host     = aws_db_instance.wordpress.address
    db_name     = var.rds_wp_db_name
    db_user     = random_pet.rds_wp_db_user.id
    db_password = random_password.rds_wp_db_password.result
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "sg_web" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.env_name_short}-sg-web"
  description = "Allow filtered inbound traffic to web"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    for item in var.sg_web_ingress : {
      from_port                = item.dst_port
      to_port                  = item.dst_port
      protocol                 = item.protocol
      description              = item.description
      source_security_group_id = module.sg_alb.security_group_id
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

resource "aws_instance" "web" {
  count = 1

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  subnet_id = element(module.vpc.private_subnets, count.index)

  vpc_security_group_ids = [
    module.sg_web.security_group_id
  ]

  iam_instance_profile = aws_iam_instance_profile.ssm_session_manager.name

  user_data = data.template_file.wordpress_script.rendered

  tags = {
    Name = "${var.env_name_short}-web-${count.index + 1}"
  }

  depends_on = [
    aws_db_instance.wordpress
  ]
}
