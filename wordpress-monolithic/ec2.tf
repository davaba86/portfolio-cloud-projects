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
