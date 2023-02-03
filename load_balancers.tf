module "public_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.2"

  name = "public"

  load_balancer_type               = "application"
  ip_address_type                  = "ipv4"
  vpc_id                           = module.vpc.vpc_id
  subnets                          = module.vpc.public_subnets
  enable_cross_zone_load_balancing = true
  create_lb                        = var.enable_expensive

  security_groups = [
    module.public_alb_sg_external_web.security_group_id,
    module.public_alb_sg_internal.security_group_id,
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"

      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.wildcard_certificate.acm_certificate_arn
      action_type     = "fixed-response"

      fixed_response = {
        content_type = "text/plain"
        message_body = ""
        status_code  = 200
      }
    },
  ]

  tags = local.tags
}

module "public_alb_sg_external_web" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "public-alb-sg-external-web"
  description = "Public ALB security group allowing HTTP and HTTPS access from the internet"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "public_alb_sg_internal" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "public-alb-sg-internal"
  description = "Public ALB security group used for internal security rules (eg services permitting forwarded traffic)"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  tags = local.tags
}

locals {
  public_alb_https_listener_id  = one(module.public_alb.https_listener_ids)
  public_alb_https_listener_arn = one(module.public_alb.https_listener_arns)
  public_alb_sg_internal_id     = module.public_alb_sg_internal.security_group_id
}
