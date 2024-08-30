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
    }
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  fargate_profiles = [
    {
      name       = "main"
      subnet_ids = module.vpc.private_subnets
      selectors  = [{ namespace = "*" }]
    }
  ]

  tags = local.tags
}
