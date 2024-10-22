data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "base_alb"
  }
}

resource "aws_security_group" "sg_public_source" {
  name        = "alb-public-source"
  description = "Source security group for rules that allow traffic from the public ALB (e.g. assigned to k8s TargetGroupBinding to allow ALB traffic to Fargate pods)"
  vpc_id      = var.vpc_id

  tags = local.tags
}

module "alb_public" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${var.project_name}-${var.env_name}-public"
  vpc_id                     = var.vpc_id
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
  create_security_group      = true

  security_group_ingress_rules = merge(
    merge(
      {
        for name, cidr in var.allowed_ipv4 :
        "${name}_http" => {
          from_port   = 80
          to_port     = 80
          ip_protocol = "tcp"
          description = "HTTP web traffic from ${name}"
          cidr_ipv4   = cidr
        }
      },
      {
        for name, cidr in var.allowed_ipv4 :
        "${name}_https" => {
          from_port   = 443
          to_port     = 443
          ip_protocol = "tcp"
          description = "HTTPS web traffic from ${name}"
          cidr_ipv4   = cidr
        }
      }
    )
  )

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_tags = local.tags

  security_groups = [aws_security_group.sg_public_source.id]

  listeners = {
    redirect_http_to_https = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  tags = local.tags
}

resource "aws_alb_listener" "alb_public_https_listener" {
  load_balancer_arn = module.alb_public.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.wildcard_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = 404
    }
  }
}
