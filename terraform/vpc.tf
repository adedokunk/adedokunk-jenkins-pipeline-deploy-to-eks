# data "aws_availability_zones" "azs" {}
# module "myapp-vpc" {
#   source          = "terraform-aws-modules/vpc/aws"
#   version         = "3.19.0"
#   name            = "myapp-vpc"
#   cidr            = var.vpc_cidr_block
#   private_subnets = var.private_subnet_cidr_blocks
#   public_subnets  = var.public_subnet_cidr_blocks
#   azs             = data.aws_availability_zones.azs.names

#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true

#   tags = {
#     "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
#   }

#   public_subnet_tags = {
#     "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
#     "kubernetes.io/role/elb"                  = 1
#   }

#   private_subnet_tags = {
#     "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
#     "kubernetes.io/role/internal-elb"         = 1
#   }
# }

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "utrains-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "node_group_two" {
  name_prefix = "node_group_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "utrains-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}
