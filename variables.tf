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

variable "allowed_ips" {
  type    = list(string)
  default = ["0.0.0.0/32"]
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
