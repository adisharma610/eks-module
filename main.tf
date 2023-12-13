# AWS Provider configuration specifying the region
provider "aws" {
  region = "us-east-1"
}

# Module for creating a VPC with public and private subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "myvpc"
  cidr               = "15.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b", ]
  private_subnets    = ["15.0.1.0/24", "15.0.2.0/24"]
  public_subnets     = ["15.0.101.0/24", "15.0.102.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Module for creating an Amazon EKS cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = "my-first-cluster"
  cluster_endpoint_public_access = true
  # cluster_addons = {
  #   coredns = {
  #     preserve    = true
  #     most_recent = true
  #
  #     timeouts = {
  #       create = "25m"
  #       delete = "10m"
  #     }
  #   }
  #   kube-proxy = {
  #     most_recent = true
  #   }
  #   vpc-cni = {
  #     most_recent = true
  #   }
  # }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Additional security group rules for the EKS cluster
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Additional security group rules for node-to-node communication
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # this block is for creating eks-managed-node-group that will create in the cluster
  # but I created a module for eks-managed-node-groups for maintaining clean code
  #   eks_managed_node_groups = {
  #     my-first-cluster-wg= {
  #       min_size     = 1
  #       max_size     = 2
  #       desired_size = 1
  #
  #       instance_types = ["t2.micro"]
  #       capacity_type  = "SPOT"
  #
  #
  #       tags = {
  #         ExtraTag = "example"
  #       }
  #     }
  #   }

  # this block is for creating Fargate profile that will create in the cluster
  # but I created a module for Fargate-profile for maintaining clean code
  # Fargate Profile(s)
  # fargate_profiles = {
  #   default = {
  #     name = "default"
  #     selectors = [
  #       {
  #         namespace = "kube-system"
  #         labels = {
  #           k8s-app = "kube-dns"
  #         }
  #       },
  #       {
  #         namespace = "default"
  #       }
  #     ]
  #
  #     tags = {
  #       Owner = "test"
  #     }
  #
  #     timeouts = {
  #       create = "20m"
  #       delete = "20m"
  #     }
  #   }
  # }

  # AWS authentication configuration for EKS
  aws_auth_node_iam_role_arns_non_windows = [module.eks_managed_node_group.iam_role_arn]

  aws_auth_fargate_profile_pod_execution_role_arns = [module.fargate_profile.fargate_profile_pod_execution_role_arn]

  aws_auth_roles = [
    {
      rolearn  = module.eks_managed_node_group.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = module.fargate_profile.fargate_profile_pod_execution_role_arn
      username = "system:node:{{SessionName}}"
      groups   = ["system:bootstrappers", "system:nodes", "system:node-proxier"]
    },
  ]
}

# Module for creating a separate Fargate profile. That is useful because it is easy to manage and looks clean code
module "fargate_profile" {
  source       = "terraform-aws-modules/eks/aws//modules/fargate-profile"
  name         = "separate-fargate-profile"
  cluster_name = module.eks.cluster_name

  subnet_ids = module.vpc.private_subnets
  selectors = [{
    namespace = "kube-system"
  }]
}

# Module for creating an EKS managed node group. That is useful because it is easy to manage and looks clean code
module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name                              = "separate-eks-mng"
  cluster_name                      = module.eks.cluster_name
  cluster_version                   = module.eks.cluster_version
  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,
  ]
  min_size       = 1
  max_size       = 2
  desired_size   = 1
  instance_types = ["t2.micro"]
  capacity_type  = "SPOT"
}
