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

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "fargate_subnet_ids" {
  type = list(string)
}

variable "enable_fargate" {
  type        = bool
  default     = true
  description = "Enable Fargate for all pods. Disabling this enables node groups instead."
}

variable "instance_type" {
  type        = string
  default     = "t4g.medium"
  description = "EC2 instance type to use for EKS node group; ensure they have a high IP count (the default has 18 IPs)"
}

variable "min_nodes" {
  type    = number
  default = 2
}

variable "max_nodes" {
  type    = number
  default = 3
}
