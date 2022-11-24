output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "public_subnet_arns" {
  value = module.vpc.public_subnet_arns
}

output "private_subnet_arns" {
  value = module.vpc.private_subnet_arns
}
