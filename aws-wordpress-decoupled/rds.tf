resource "aws_db_subnet_group" "wordpress" {
  name       = "rds-private-subnet-group"
  subnet_ids = module.vpc.database_subnets
}

module "sg_db" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.env_name_short}-sg-db"
  description = "Allow web inbound traffic to DB"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL traffic from VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
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

resource "random_pet" "rds_admin_user" {
  length = 1
}

resource "random_password" "rds_admin_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "wordpress" {
  identifier            = var.rds_wp_db_name
  engine                = "mysql"
  engine_version        = "8.0.34"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 1000

  username = random_pet.rds_admin_user.id
  password = random_password.rds_admin_password.result

  db_name = var.rds_wp_db_name

  vpc_security_group_ids = [module.sg_db.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  parameter_group_name   = "default.mysql8.0"

  storage_encrypted     = true
  copy_tags_to_snapshot = true
  skip_final_snapshot   = true
}
