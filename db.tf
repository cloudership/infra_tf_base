resource "random_password" "db_admin_password" {
  length  = 63
  special = false
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.env_name}-${var.project_name}"

  # List all available versions: `aws rds describe-db-engine-versions --engine postgres | jq -Mr '.DBEngineVersions[].DBEngineVersionDescription'`
  engine                   = "postgres"
  engine_version           = "16.4"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  instance_class           = "db.t4g.micro"
  storage_type             = "gp2"

  allocated_storage     = 20
  max_allocated_storage = 20

  multi_az                  = false
  create_db_option_group    = false
  create_db_parameter_group = false
  apply_immediately         = true
  skip_final_snapshot       = true

  username                    = var.db_admin_username
  manage_master_user_password = false
  password                    = random_password.db_admin_password.result
  port                        = "5432"

  vpc_security_group_ids = [module.sg_rds_access.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  tags = local.tags
}

module "sg_rds_access" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${var.env_name}-${var.project_name}-rds-access"
  description = "PostgreSQL access from within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["postgresql-tcp"]

  tags = local.tags
}

resource "aws_route53_record" "db" {
  zone_id = module.domains.route53_zone_public_id
  name    = "db.internal"
  type    = "CNAME"
  ttl     = 300
  records = [module.db.db_instance_address]
}
