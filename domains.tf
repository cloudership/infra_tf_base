resource "aws_route53_zone" "public" {
  name = "prod.${var.project_name}.service.${var.root_domain}"

  tags = local.tags
}

resource "aws_route53_zone" "private" {
  name = "prod.local"

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = local.tags
}

module "wildcard_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.3.2"

  domain_name         = "*.${trimsuffix(aws_route53_zone.public.name, ".")}"
  zone_id             = aws_route53_zone.public.id
  wait_for_validation = false

  tags = local.tags
}
