locals {
  vpc_cidr         = "${var.vpc_subnet_address}/${var.vpc_subnet_mask_bits}"
  subnet_addresses = [for cidr_block in cidrsubnets(local.vpc_cidr, 1, 1) : cidrsubnets(cidr_block, 2, 2, 2)]
}

data "aws_region" "current" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = local.vpc_cidr

  azs             = formatlist("${data.aws_region.current.name}%s", var.aws_availability_zone_letters)
  private_subnets = local.subnet_addresses[0]
  public_subnets  = local.subnet_addresses[1]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Project = var.project_name
    EnvName   = var.env_name
    Component = "base"
  }
}
