# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cluster_suffix" {
  description = "suffix for cluster to ensure uniqueness in naming"
  type = string
  default = "playground"
}