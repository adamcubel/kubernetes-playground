variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
 
variable "vpc_id" {
  description = "ID of the VPC to deploy the cluster"
  type = string
  default = ""
}
 
variable "eks_subnet_ids" {
  description = "List of subnet IDs to use when deploying the cluster"
  default = []
}
 
variable "eks_cluster_name" {
  description = "name for cluster"
  type = string
  default = "playground"
}
 
variable "eks_cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type = string
  default = "1.29"
}
 
variable "eks_node_group_instance_types" {
  description = "collection of instance types for EC2 resources deployed in this EKS module"
  default = ["t3.medium"]
}
 
variable "eks_node_group_min_size" {
  description = "minimum number of nodes in the node group"
  type = number
  default = 1
}
 
variable "eks_node_group_max_size" {
  description = "maximum number of nodes in the node group"
  type = number
  default = 4
}
 
variable "eks_node_group_desired_size" {
  description = "desired number of nodes in the node group"
  type = number
  default = 2
}
 
variable "eks_create_iam_role" {
  description = "boolean to create iam role"
  type = bool
  default = false
}
 
variable "eks_role_arn" {
  description = "ARN of the role to use for the EKS cluster"
  type = string
  default = ""
}
 
variable "eks_create_kms_key" {
  description = "boolean to create KMS key EKS will use for encryption"
  type = bool
  default = false
}
 
variable "eks_kms_key_arn" {
  description = "ARN for KMS Key to use with EKS"
  type = string
  default = ""
}
 
variable "eks_create_cluster_security_group" {
  description = "boolean to create cluster security group"
  type = bool
  default = false
}
 
variable "eks_security_group_id" {
  description = "ID of Security Group to use when deploying EKS"
  type = string
  default = "tf-eks-sg"
}
 
variable "eks_create_node_security_group" {
  description = "boolean to create cluster node security group"
  type = bool
  default = false
}
 
variable "eks_node_security_group_id" {
  description = "ID of Security Group to use for nodes when deploying EKS"
  default = "tf-eks-node-sg"
}
 
variable "eks_number_of_node_groups" {
  type = number
  default = 2
}
 
variable "tags" {
  description = "collection of tags used for resources deployed in this module"
  default = {}
}
 
variable "eks_create_node_group_iam_role" {
  description = ""
  default = true
  type = bool
}
 
variable "eks_node_group_iam_arn" {
  description = ""
  default = ""
  type = string
}
 
variable "eks_sg_additional_rules_cidr" {
  description = "CIDRs to allow ingress to cluster"
  default = []
}