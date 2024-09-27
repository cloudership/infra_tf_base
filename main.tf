data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  vpc_cidr = "${var.subnet_address}/${var.subnet_mask_bits}"

  # First divide vpc_cidr into 2 subnets of equal size (1 bit smaller than vpc_cidr) for public and private subnets.
  # Then divide each of the public and private subnets into 3 smaller subnets, each 2 bits smaller than those, so both
  # public and private subnets have 3 equal-sized smaller subnets, one for each AZ.
  subnet_addresses = [for cidr_block in cidrsubnets(local.vpc_cidr, 1, 1) : cidrsubnets(cidr_block, 2, 2, 2)]

  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "base"
  }
}

module "domains" {
  source       = "./domains"
  aws_region   = var.aws_region
  env_name     = var.env_name
  project_name = var.project_name
  root_domain  = var.root_domain
}

module "alb" {
  source                   = "./alb"
  aws_region               = var.aws_region
  env_name                 = var.env_name
  project_name             = var.project_name
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  wildcard_certificate_arn = module.domains.public_wildcard_certificate_arn
  allowed_ipv4             = var.allowed_ipv4
}
