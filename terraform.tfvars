name= "my_vpc"
cidr_vpc = ["15.0.0.0/16","17.0.0.0/16"]
azs_vpc = [ "us-east-1a","us-east-1b","us-east-1c" ]
# vpc_private_subnets = ["15.0.1.0/24", "15.0.2.0/24", "15.0.3.0/24"]
# vpc_public_subnets  = ["15.0.101.0/24", "15.0.102.0/24", "15.0.103.0/24"]
enable_nat_gateway = false
enable_vpn_gateway = false
multiple_vpc = true
no_vpc = 2


# 19.0.0.0/24","25.0.0.0/24
# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = var.name
#   cidr = var.cidr_vpc/24

#   azs             = var.azs_vpc
#   private_subnets = var.vpc_private_subnets/24
#   public_subnets  = var.vpc_public_subnets/24
  

#   enable_nat_gateway = var.enable_nat_gateway
#   enable_vpn_gateway = var.enable_vpn_gateway

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }
