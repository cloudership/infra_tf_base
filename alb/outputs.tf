output "zone_id" {
  value       = module.alb_public.zone_id
  description = "Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
}

output "dns_name" {
  value       = module.alb_public.dns_name
  description = "Canonical DNS name of the load balancer (to be used in a Route 53 Alias record)."
}

output "https_listener_arn" {
  value       = aws_alb_listener.alb_public_https_listener.arn
  description = "ARN of the HTTPS listener - used to attach listener rules and target groups"
}
