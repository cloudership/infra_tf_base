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
  version = "~> 20.26"

  cluster_name    = "${var.project_name}-main"
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }

  # EKS Addons
  cluster_addons = {
    coredns = {
      "addon_version" = "v1.11.3-eksbuild.1"
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

  fargate_profiles = {
    main = {
      create = var.enable_fargate

      subnet_ids = var.fargate_subnet_ids
      selectors  = [{ namespace = "*" }]
    }
  }

  eks_managed_node_groups = {
    main = {
      create = !var.enable_fargate

      instance_types = [var.instance_type]
      min_size       = var.min_nodes
      max_size       = var.max_nodes
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = var.min_nodes
    }
  }

  tags = local.tags
}

data "aws_eks_cluster_auth" "main_eks_cluster" {
  name = module.main_eks_cluster.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = module.main_eks_cluster.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.main_eks_cluster.token
    cluster_ca_certificate = base64decode(module.main_eks_cluster.cluster_certificate_authority_data)
  }
}
