# module "eks" {
#     source  = "terraform-aws-modules/eks/aws"
#     version = "~> 19.0"
#     cluster_name = "myapp-eks-cluster"
#     cluster_version = "1.27"
    

#     cluster_endpoint_public_access  = true

#     vpc_id = module.myapp-vpc.vpc_id
#     subnet_ids = module.myapp-vpc.private_subnets

#     tags = {
#         environment = "development"
#         application = "myapp"
#     }

#     eks_managed_node_groups = {
#         dev = {
#             min_size = 1
#             max_size = 3
#             desired_size = 2

#             instance_types = ["t2.small"]
#         }
#     }
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }

  required_version = ">= 1.2.0"
}




module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = false

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      pre_bootstrap_user_data = <<-EOT
      echo 'foo bar'
      EOT

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      pre_bootstrap_user_data = <<-EOT
      echo 'foo bar'
      EOT

      vpc_security_group_ids = [
        aws_security_group.node_group_two.id
      ]
    }
  }
}

