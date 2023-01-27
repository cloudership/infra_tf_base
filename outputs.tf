output "vpc_arn" {
  value = module.vpc.vpc_arn
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
