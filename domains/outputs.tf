output "route53_zone_public_id" {
  value = aws_route53_zone.public.id
}

output "public_domain_prefix" {
  value = aws_route53_zone.public.name
}

output "public_wildcard_certificate_arn" {
  value = module.wildcard_certificate.acm_certificate_arn
}
