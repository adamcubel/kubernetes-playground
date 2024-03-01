# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the cluster"
  type = string
}

variable "cluster_suffix" {
  description = "suffix for cluster to ensure uniqueness in naming"
  type = string
  default = "playground"
}

variable "eks_access_entries" {
  description = "Map of access entries to add to the cluster"
  default = {}
}

variable "eks_cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type = string
  default = "1.29"
}