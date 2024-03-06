# Variables to use for deployment

region = "us-east-1"
vpc_id = "vpc-00dcbcc94e3e1ecfe"
eks_subnet_ids = ["subnet-03fe28429500ac1ef", "subnet-06585c320073f52bf", "subnet-0bdaf01619569adc2"]
tags = {}

# EKS Cluster specific knobs
eks_cluster_name = "sisyphus"
eks_cluster_version = "1.29"

eks_node_group_instance_types = ["t3.medium"]
eks_node_group_min_size = 1
eks_node_group_max_size = 4
eks_node_group_desired_size = 2

eks_create_iam_role = true
eks_role_name = "aws-k8s-role"

eks_create_kms_key = true
eks_kms_key_arn = ""

eks_create_cluster_security_group = true
eks_security_group_name = "sisyphus-cluster-sg"

eks_create_node_security_group = true
eks_node_security_group_name = "sisyphus-cluster-node-sg"
