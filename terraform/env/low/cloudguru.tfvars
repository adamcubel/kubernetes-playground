# Variables to use for deployment

region = "us-east-1"
vpc_id = "vpc-0b0b351e59b2f2635"
eks_subnet_ids = ["subnet-06e0859ef6c2487c8", "subnet-07c8d920f8f03a8b2", "subnet-037ef0653c6e878af"]
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
