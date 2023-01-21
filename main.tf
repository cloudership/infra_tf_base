locals {
  vpc_cidr         = "${var.vpc_subnet_address}/${var.vpc_subnet_mask_bits}"
  subnet_addresses = [for cidr_block in cidrsubnets(local.vpc_cidr, 1, 1) : cidrsubnets(cidr_block, 2, 2, 2)]

  tags = {
    Terraform = "true"
    Project   = var.project_name
    EnvName   = var.env_name
    Component = "base"
  }
}

data "aws_region" "current" {}
