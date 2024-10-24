variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "enable_expensive" {
  type    = bool
  default = true
}

variable "allowed_ipv4" {
  type        = map(string)
  description = "Named list of IP address ranges allowed to access the public ALB. Defaults to unrestricted access"
  default     = { all = "0.0.0.0/0" }
}

variable "aws_availability_zone_letters" {
  type        = list(string)
  description = <<-EOT
    The letters of the availability zones to use, e.g. ["a", "b", "c"]
  EOT
  default     = ["a", "b", "c"]
}

variable "subnet_address" {
  type        = string
  description = "Subnet address for the VPC, e.g. 10.127.0.0"
}

variable "subnet_mask_bits" {
  type        = number
  description = "Subnet mask bits e.g. 16. Recommended this be set to 16"
}

variable "nat_instance_type" {
  type        = string
  description = <<-EOT
  Instance type to use for the NAT instance. No default - set it carefully to take advantage of the free tier.
  Generally, t2.micro qualifies for the free tier, except for some regions like eu-north-1 where t3.micro qualifies the
  free tier instead.
  EOT
}

variable "db_admin_username" {
  type        = string
  description = "admin user for the PostgreSQL RDS instance"
  default     = "root"
}
