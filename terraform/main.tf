# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  cluster_name = "nifi-${var.cluster_suffix}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_vpc" "cluster_vpc" {
  id = var.vpc_id
}

# resource "aws_security_group" "eks" {
#   name        = "${var.cluster_suffix} eks cluster"
#   description = "Allow traffic"
#   vpc_id      = data.aws_vpc.cluster_vpc.id

#   ingress {
#     description      = "World"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = merge({
#     Name = "EKS ${var.cluster_suffix}",
#     "kubernetes.io/cluster/${local.cluster_name}": "owned"
#   }, var.tags)
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"
  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id                         = data.aws_vpc.cluster_vpc.id
  subnet_ids                     = var.subnet_ids
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true
  # cluster_additional_security_group_ids = [aws_security_group.eks.id]
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      capacity_type  = "SPOT"
      instance_types = ["t3.medium"]
      
      min_size     = 1
      max_size     = 6
      desired_size = 2
    }

    two = {
      name = "node-group-2"
      capacity_type  = "SPOT"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 6
      desired_size = 2
    }
  }
}