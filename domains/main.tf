data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "base_domains"
  }
}

resource "aws_route53_zone" "public" {
  name    = "${var.env_name}.${var.project_name}.service.${var.root_domain}"
  comment = "Public ${var.env_name} domain of the ${var.project_name} project"
  tags    = local.tags
}

module "wildcard_certificate" {
  source = "terraform-aws-modules/acm/aws"

  domain_name               = trimsuffix(aws_route53_zone.public.name, ".")
  subject_alternative_names = ["*.${trimsuffix(aws_route53_zone.public.name, ".")}"]
  zone_id                   = aws_route53_zone.public.id
  validation_method         = "DNS"
  wait_for_validation       = false

  tags = local.tags
}
