output "zone_id" {
  value       = module.alb_public.zone_id
  description = "Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
}

output "https_listener_arn" {
  value = "ARN of the HTTPS listener - used to attach listener rules and target groups"
}
