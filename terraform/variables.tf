# variable "vpc_cidr_block" {}
# variable "private_subnet_cidr_blocks" {}
# variable "public_subnet_cidr_blocks" {}

# variable "enable_classiclink" {
#   type    = bool
#   default = null
# }

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
