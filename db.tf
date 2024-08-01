# module "db" {
#   source = "terraform-aws-modules/rds/aws"
#
#   identifier = "${var.env_name}-${var.project_name}"
#
#   # All available versions: `$ aws rds describe-db-engine-versions --default-only --engine postgres`
#   engine                   = "postgres"
#   engine_version           = "16.3"
#   engine_lifecycle_support = "open-source-rds-extended-support-disabled"
#   instance_class           = "db.t4g.large"
#
#   allocated_storage     = 20
#   max_allocated_storage = 20
#
#   username = var.db_admin_username
#   port     = "5432"
#
#   vpc_security_group_ids = ["sg-12345678"]
#
#   maintenance_window = "Mon:00:00-Mon:03:00"
#   backup_window      = "03:00-06:00"
#
#   # DB subnet group
#   create_db_subnet_group = true
#   subnet_ids             = ["subnet-12345678", "subnet-87654321"]
#
#   tags = local.tags
# }
#
# module "security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.0"
#
#   name        = "db-sg-${var.env_name}-${var.project_name}"
#   description = "Complete PostgreSQL example security group"
#   vpc_id      = module.vpc.vpc_id
#
#   # ingress
#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 5432
#       to_port     = 5432
#       protocol    = "tcp"
#       description = "PostgreSQL access from within VPC"
#       cidr_blocks = module.vpc.vpc_cidr_block
#     },
#   ]
#
#   tags = local.tags
# }


# variable "db_admin_username" {
#   type        = string
#   description = "admin user for the PostgreSQL RDS instance"
#   default     = "admin"
# }
