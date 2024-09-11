data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "base_eks"
  }
}

module "main_eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = "${var.project_name}-main"
  cluster_version = "1.30"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }

  # EKS Addons
  cluster_addons = {
    coredns = {
      "addon_version" = "v1.11.1-eksbuild.11"
      timeouts = {
        create = "60m"
        update = "60m"
      }
    }
    kube-proxy = {}
    vpc-cni    = {}
    # Disabled - Fargate pods don't support it, no point wasting money running it
    # eks-pod-identity-agent = {}
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  fargate_profiles = [
    {
      name       = "main"
      subnet_ids = var.fargate_subnet_ids
      selectors  = [{ namespace = "*" }]
    }
  ]

  tags = local.tags
}
