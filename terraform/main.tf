# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

locals {
  cluster_name = "dt-nifi-${var.cluster_suffix}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_vpc" "cluster_vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "eks" {
  name        = "${var.cluster_suffix} eks cluster"
  description = "Allow traffic"
  vpc_id      = data.aws_vpc.cluster_vpc.id

  ingress {
    description      = "World"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
    Name = "EKS ${var.cluster_suffix}",
    "kubernetes.io/cluster/${local.cluster_name}": "owned"
  }, var.tags)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"
  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id                         = data.aws_vpc.cluster_vpc.id
  subnet_ids                     = var.subnet_ids
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true
  cluster_additional_security_group_ids = [aws_security_group.eks.id]
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      capacity_type  = "SPOT"
      instance_types = ["t3.small"]
      
      min_size     = 1
      max_size     = 6
      desired_size = 3
    }

    two = {
      name = "node-group-2"
      capacity_type  = "SPOT"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 6
      desired_size = 3
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
# data "aws_iam_policy" "ebs_csi_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# module "irsa-ebs-csi" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "4.7.0"

#   create_role                   = true
#   role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
#   provider_url                  = module.eks.oidc_provider
#   role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
# }

# resource "aws_eks_addon" "ebs-csi" {
#   cluster_name             = module.eks.cluster_name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.20.0-eksbuild.1"
#   service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
#   tags = {
#     "eks_addon" = "ebs-csi"
#     "terraform" = "true"
#   }
# }