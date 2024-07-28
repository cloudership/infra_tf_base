module "public_alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "${var.project_name}-public-alb"

  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  security_groups = [
    module.public_alb_sg_external_web.security_group_id,
    module.public_alb_sg_internal.security_group_id,
  ]

  listeners = [
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

  tags = local.tags
}

module "public_alb_sg_external_web" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.project_name}-public-alb-sg-external-web"
  description = "Public ALB security group allowing HTTP and HTTPS access from the internet"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.allowed_ips
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "public_alb_sg_internal" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.project_name}-public-alb-sg-internal"
  description = "Public ALB security group used for internal security rules (eg services that use this LB as rev proxy)"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  tags = local.tags
}

locals {
  public_alb_https_listener_id  = try(module.public_alb.listeners[0].id, null)
  public_alb_https_listener_arn = try(module.public_alb.listeners[0].arn, null)
  public_alb_sg_internal_id     = module.public_alb_sg_internal.security_group_id
}
