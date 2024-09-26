output "eks_cluster_main_name" {
  value = module.main_eks_cluster.cluster_name
}

output "eks_cluster_main_arn" {
  value = module.main_eks_cluster.cluster_arn
}

output "eks_cluster_main_oidc_provider_name" {
  value = module.main_eks_cluster.oidc_provider
}

output "eks_cluster_main_oidc_provider_arn" {
  value = module.main_eks_cluster.oidc_provider_arn
}

output "eks_cluster_main_sg_id" {
  value = module.main_eks_cluster.cluster_security_group_id
}
