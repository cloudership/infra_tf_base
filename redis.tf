module "redis" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id                 = "${var.env_name}-${var.project_name}-redis"
  create_cluster             = true
  create_replication_group   = false
  at_rest_encryption_enabled = true
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t3.micro"
  multi_az_enabled           = false
  apply_immediately          = true
  auto_minor_version_upgrade = true
  create_parameter_group     = false

  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  subnet_group_name = "${var.env_name}-${var.project_name}-redis-private"
  subnet_ids        = module.vpc.private_subnets

  log_delivery_configuration = {}

  tags = local.tags
}

resource "aws_route53_record" "redis" {
  zone_id = module.domains.route53_zone_public_id
  name    = "redis.internal"
  type    = "CNAME"
  ttl     = 300
  records = [module.redis.cluster_cache_nodes[0]["address"]]
}
