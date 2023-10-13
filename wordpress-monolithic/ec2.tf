resource "tls_private_key" "ed25519_compute" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "lab" {
  key_name   = "lab-key-${lookup(var.aws_regions, "eu-west-1")}"
  public_key = tls_private_key.ed25519_compute.public_key_openssh
}

resource "local_file" "ed25519_compute_private_key" {
  content         = tls_private_key.ed25519_compute.private_key_openssh
  filename        = "private_key.pem"
  file_permission = "400"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

resource "aws_instance" "web" {
  count = 1

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  subnet_id = element(module.vpc.public_subnets, count.index)

  vpc_security_group_ids = [
    module.sg_web.security_group_id
  ]

  key_name = aws_key_pair.lab.key_name

  tags = {
    Name = "${var.env_name_short}-web-${count.index + 1}"
  }
}
