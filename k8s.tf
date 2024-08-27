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
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    main = {
      instance_types = [var.eks_instance_type]

      min_size = var.eks_min_nodes
      max_size = var.eks_max_nodes
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = var.eks_desired_nodes
    }
  }

  tags = local.tags
}

/* Example of a Fargate profile - would only work if private subnets could access a NAT gateway or instance
module "main_eks_cluster_main_fargate_profile" {
  source  = "terraform-aws-modules/eks/aws//modules/fargate-profile"
  version = "~> 20.24"

  name         = "main"
  cluster_name = module.main_eks_cluster.cluster_name
  subnet_ids   = module.vpc.private_subnets
  selectors    = [{ namespace = "*" }]
}
*/
