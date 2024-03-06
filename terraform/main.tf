# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "cluster_vpc" {
  id = var.vpc_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"
  cluster_name = var.eks_cluster_name
  cluster_version = var.eks_cluster_version


  # create_cni_ipv6_iam_policy = var.eks_create_cni_ipv6_iam_policy
  create_iam_role  = var.eks_create_iam_role
  iam_role_arn = var.eks_create_iam_role == true ? null : var.eks_role_arn

  create_kms_key = var.eks_create_kms_key
  cluster_encryption_config = {
    provider_key_arn = var.eks_create_kms_key == true ? null : var.eks_kms_key_arn
    resources = ["secrets"]
  }

  create_cluster_security_group = var.eks_create_cluster_security_group
  cluster_security_group_id = var.eks_create_cluster_security_group == true ? null : var.eks_security_group_id
  create_node_security_group = var.eks_create_node_security_group 
  node_security_group_id = var.eks_create_cluster_security_group == true ? null : var.eks_node_security_group_id

  vpc_id                         = data.aws_vpc.cluster_vpc.id
  subnet_ids                     = var.eks_subnet_ids
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true
  # cluster_additional_security_group_ids = [aws_security_group.eks.id]
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    for i in range(1, var.number_of_node_groups) : "node_${i}" => {
      name = "node-group-${i}"
      instance_types = var.eks_node_group_instance_types     
      min_size     = var.eks_node_group_min_size
      max_size     = var.eks_node_group_max_size
      desired_size = var.eks_node_group_desired_size
    }
  }
}