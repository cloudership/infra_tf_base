variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "wildcard_certificate_arn" {
  type        = string
  description = "ARN of a wildcard certificate to cover all domains that will be served by the load balancers."
}
