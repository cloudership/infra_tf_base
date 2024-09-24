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

output "sg_id_rds_access" {
  value       = module.sg_rds_access.security_group_id
  description = "Assign this SG to have access to the RDS cluster"
}

output "sg_arn_rds_access" {
  value       = module.sg_rds_access.security_group_arn
  description = "Assign this SG to have access to the RDS cluster"
}

output "rds_hostname" {
  value       = split(":", module.db.db_instance_endpoint)[0]
  description = "Hostname of the PostgreSQL RDS instance"
}

output "rds_port" {
  value       = parseint(split(":", module.db.db_instance_endpoint)[1], 10)
  description = "Port of the PostgreSQL RDS instance"
}

output "rds_admin_username" {
  value       = var.db_admin_username
  description = "admin user's password for the PostgreSQL RDS instance"
}

output "rds_admin_password" {
  value       = random_password.db_admin_password.result
  description = "admin user's password for the PostgreSQL RDS instance"
  sensitive   = true
}

output "alb_public_zone_id" {
  value       = module.alb_public.zone_id
  description = "Canonical hosted zone ID of the public load balancer (to be used in a Route 53 Alias record)."
}

output "alb_public_https_listener_arn" {
  value       = module.alb_public.zone_id
  description = "ARN of the public ALB's HTTPS listener - used to attach listener rules and target groups"
}
