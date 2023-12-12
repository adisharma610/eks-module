provider "aws" {
  region = "us-east-1"
}

#created dynamic vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-${count.index}"
  cidr = element(var.cidr_vpc,count.index)
  count = var.multiple_vpc == true ? var.no_vpc:1

  azs             = var.azs_vpc
  private_subnets = [for i in range (length(var.azs_vpc)):cidrsubnet(element(var.cidr_vpc, count.index),8,count.index*4+i*4)]
  public_subnets  = [for i in range (length(var.azs_vpc)):cidrsubnet(element(var.cidr_vpc, count.index),8,count.index*4+i*4+1)]
  
  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
  
}

#created dynamic eks
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = "my-first-cluster-${count.index}"
  cluster_endpoint_public_access = true


  vpc_id                   = element(module.vpc[*].vpc_id,count.index)
  subnet_ids               = element(module.vpc[*].private_subnets,count.index)
  

  eks_managed_node_groups = {
    my-first-cluster-wg= {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"
      

      tags = {
        ExtraTag = "example"
      }
    }
  }
  
}