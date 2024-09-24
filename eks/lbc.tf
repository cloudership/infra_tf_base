# AWS Load Balancer Controller for EKS
# Reference:https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/
# Inspiration: https://github.com/Young-ook/terraform-aws-eks/blob/1.7.11/modules/lb-controller/main.tf
# How to upgrade: https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/README.md#Upgrade

# This JSON file is downloaded by following instructions at
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/#option-a-recommended-iam-roles-for-service-accounts-irsa
# If replacing the file, make the following changes: remove the statements for ec2:AuthorizeSecurityGroupIngress and
# ec2:RevokeSecurityGroupIngress; remove the statements for

data "local_file" "json_aws_iam_policy_document_irsa_lbc" {
  filename = "${path.module}/aws_iam_policy_document_irsa_lbc.json"
}

data "aws_iam_policy_document" "irsa_lbc_custom_policy" {
  statement {
    sid = "AllowLBCToManageIngressSecurityGroups"

    effect = "Allow"

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "ec2:Vpc"
      values   = ["arn:aws:ec2:${local.aws_region}:${local.account_id}:vpc/${var.vpc_id}"]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${module.main_eks_cluster.cluster_name}"
      values   = ["false"]
    }
  }

  statement {
    sid = "DisallowLBCFromCreatingLbResources"

    effect = "Deny"

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateRule",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "oidc_assume_role_lbc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.main_eks_cluster.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.main_eks_cluster.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.main_eks_cluster.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:AssumeRoleWithWebIdentity",
      "sts:TagSession",
    ]
  }
}

resource "aws_iam_role" "irsa_lbc" {
  name = "${title(var.project_name)}AWSLoadBalancerController"

  inline_policy {
    name   = "AllowLBCToManageResources"
    policy = data.local_file.json_aws_iam_policy_document_irsa_lbc.content
  }

  inline_policy {
    name   = "LBCCustomPolicy"
    policy = data.aws_iam_policy_document.irsa_lbc_custom_policy.json
  }

  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_lbc.json

  tags = local.tags
}

resource "helm_release" "lbc" {
  repository      = "https://aws.github.io/eks-charts"
  name            = "aws-load-balancer-controller"
  chart           = "aws-load-balancer-controller"
  version         = null
  namespace       = "kube-system"
  cleanup_on_fail = true
  atomic          = true

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.irsa_lbc.arn
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "clusterName"
    value = module.main_eks_cluster.cluster_name
  }

  set {
    name  = "enableCertManager"
    value = false
  }

  depends_on = [module.main_eks_cluster]
}
