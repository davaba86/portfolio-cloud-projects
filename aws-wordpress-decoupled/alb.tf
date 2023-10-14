module "sg_alb" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.env_name_short}-sg-alb-web"
  description = "Allow web inbound traffic to ALB"
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

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.env_name_short}-alb"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  create_security_group = false
  security_groups = [
    module.sg_alb.security_group_id
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix      = "tg-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }

      targets = {
        for compute_node in aws_instance.web :
        compute_node.tags.Name => {
          target_id = compute_node.id,
          port      = 80
        }
      }
    }
  ]
}
