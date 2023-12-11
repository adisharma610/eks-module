provider "aws" {
  region = "us-east-1"
}





module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-${count.index}"
  cidr = element(var.cidr_vpc,count.index)
  count = var.multiple_vpc == true ? var.no_vpc:1

  azs             = var.azs_vpc
  private_subnets = [cidrsubnet(element(var.cidr_vpc, count.index),8,count.index*4+0)]
  public_subnets  = [cidrsubnet(element(var.cidr_vpc, count.index),8,count.index*4+1)]
  

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
  
}

# module "subnets" {
#   source = "terraform-aws-modules/vpc/aws"

#   count = var.multiplesubnets
# }
# "${cidrsubnets(module.vpc.cidr[count.index],8,0)}"
# # module "eks" {
# #   source  = "terraform-aws-modules/eks/aws"
# #   version = "~> 19.16"

# #   cluster_name                   = "myfirstcluster"
# #   cluster_version                = "1.27" # Must be 1.25 or higher
# #   cluster_endpoint_public_access = true

# #   vpc_id     = module.vpc.vpc_id
# #   subnet_ids = module.vpc.private_subnets

# #   eks_managed_node_groups = {
# #     initial = {
# #       instance_types = ["m5.large"]

# #       min_size     = 3
# #       max_size     = 10
# #       desired_size = 5
# #     }
# #   }

# #   tags = "myfirstcluster"
# }

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
# }


# module "eks" {
#   source = "terraform-aws-modules/eks/aws"

#   cluster_name                   = "my-first-cluster"
#   cluster_endpoint_public_access = true


#   vpc_id                   = module.vpc.vpc_id
#   subnet_ids               = module.vpc.private_subnets
  

#   # EKS Managed Node Group(s)
#   eks_managed_node_group_defaults = {
#     ami_type       = "AL2_x86_64"
#     instance_types = ["t2.micro"]

#     attach_cluster_primary_security_group = true
#   }

#   eks_managed_node_groups = {
#     my-first-cluster-wg= {
#       min_size     = 1
#       max_size     = 2
#       desired_size = 1

#       instance_types = ["t2.micro"]
#       capacity_type  = "SPOT"
      

#       tags = {
#         ExtraTag = "example"
#       }
#     }
#   }

 

  
# }