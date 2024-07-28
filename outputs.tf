output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_arns" {
  value = module.vpc.public_subnet_arns
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_arns" {
  value = module.vpc.private_subnet_arns
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_alb" {
  value = {
    sg_internal_id     = local.public_alb_sg_internal_id
    https_listener_arn = local.public_alb_https_listener_arn
    lb_dns_name        = module.public_alb.lb_dns_name
    lb_zone_id         = module.public_alb.lb_zone_id
  }
}

output "route53_zone_public_id" {
  value = aws_route53_zone.public.id
}
