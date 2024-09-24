data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "base_alb"
  }
}

module "alb_public" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${var.project_name}-${var.env_name}-${var.name}"
  vpc_id                     = var.vpc_id
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

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
