# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "cluster_vpc" {
  id = var.vpc_id
}

data "aws_iam_role" "aws_k8s_role" {
  count = var.eks_create_iam_role == true ? 0 : 1
  name = var.eks_role_name
}

resource "aws_iam_role" "aws_k8s_role" {
  count = var.eks_create_iam_role == true ? 1 : 0
  name = var.eks_role_name

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "KmsFunctions",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:ListGrants"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "MetricsAccess",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "XRayAccess",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "QueueAccess",
            "Action": [
                "sqs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "DynamoPeriodicTasks",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:GetRecords",
                "dynamodb:DescribeTable",
                "dynamodb:DescribeLimits",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:DescribeReservedCapacityOfferings",
                "dynamodb:DescribeReservedCapacity",
                "dynamodb:ListTagsOfResource",
                "dynamodb:ListTables",
                "dynamodb:UpdateItem"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws-us-gov:dynamodb:*:*:table/*-stack-AWSEBWorkerCronLeaderRegistry*"
            ]
        },
        {
            "Sid": "CloudWatchLogsAccess",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "RestrictCloudWatchLogsAccess",
            "Action": [
                "logs:*"
            ],
            "Effect": "Deny",
            "Resource": [
                "arn:aws-us-gov:logs:*:*:log-group:Cloudtrail*",
                "arn:aws-us-gov:logs:*:*:log-group:CudaLOGS*",
                "arn:aws-us-gov:logs:*:*:log-group:vpc*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:GetManifest",
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ssm:PutParameter",
                "ssm:AddTagsToResource"
            ],
            "Resource": "*"
        },
        {
            "Sid": "PatchManagerAccess",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:List*",
                "secretsmanager:Describe*",
                "secretsmanager:Get*"
            ],
            "Resource": "*",
            "Condition": {
                "ForAnyValue:StringEquals": {
                    "secretsmanager:ResourceTag/MISSION_SYSTEM_OWNED": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "rds:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudtrail:Get*",
                "cloudtrail:Describe*",
                "cloudtrail:List*",
                "cloudtrail:LookupEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECSAccess",
            "Effect": "Allow",
            "Action": [
                "ecs:Poll",
                "ecs:StartTask",
                "ecs:StopTask",
                "ecs:DiscoverPollEndpoint",
                "ecs:StartTelemetrySession",
                "ecs:RegisterContainerInstance",
                "ecs:DeregisterContainerInstance",
                "ecs:DescribeContainerInstances",
                "ecs:Submit*",
                "ecs:DescribeTasks",
                "ecs:ExecuteCommand"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECRPermissions",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:PutImageTagMutability",
                "ecr:StartImageScan",
                "ecr:ListTagsForResource",
                "ecr:UploadLayerPart",
                "ecr:BatchDeleteImage",
                "ecr:DeleteRepository",
                "ecr:CompleteLayerUpload",
                "ecr:TagResource",
                "ecr:DeleteRepositoryPolicy",
                "ecr:GetLifecyclePolicy",
                "ecr:PutLifecyclePolicy",
                "ecr:DescribeImageScanFindings",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:CreateRepository",
                "ecr:PutImageScanningConfiguration",
                "ecr:DeleteLifecyclePolicy",
                "ecr:PutImage",
                "ecr:UntagResource",
                "ecr:StartLifecyclePolicyPreview",
                "ecr:InitiateLayerUpload"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EC2Permissions",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "autoscaling:DescribeTags",
                "ec2:AssignPrivateIpAddresses",
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:Describe*",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:CreateVolume",
                "ec2:ModifyVolume",
                "ec2:AttachVolume",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot",
                "ec2:UnassignPrivateIpAddresses",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "route53:ChangeResourceRecordSets",
                "route53:GetChange",
                "route53:List*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageEC2Messages",
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Deny",
            "Action": "s3:*",
            "Resource": [
                "arn:aws-us-gov:s3:::common*",
                "arn:aws-us-gov:s3:::common-*/*",
                "arn:aws-us-gov:s3:::cloudtrail*",
                "arn:aws-us-gov:s3:::cloudtrail*/*",
                "arn:aws-us-gov:s3:::config*",
                "arn:aws-us-gov:s3:::config*/*",
                "arn:aws-us-gov:s3:::ec2-ccewincert*",
                "arn:aws-us-gov:s3:::ec2-ccewincert*/*",
                "arn:aws-us-gov:s3:::ec2-stigscriptbucket*",
                "arn:aws-us-gov:s3:::ec2-stigscriptbucket*/*"
            ]
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws-us-gov:iam::399741539502:role/aws-ecs-tasks-role"
            ],
            "Effect": "Allow",
            "Sid": "AllowECSTasksPassRole"
        },
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "arn:aws-us-gov:iam::399741539502:role/aws-k8s-role",
                "arn:aws-us-gov:iam::399741539502:role/aws-k8s-role-worker"
            ],
            "Effect": "Allow",
            "Sid": "AllowKiamAssumeSelf"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_k8s_role_attach" {
  count = var.eks_create_iam_role != false ? 1 : 0
  role       = one(aws_iam_role.aws_k8s_role[*].name)
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_kms_key" "eks_key" {
  count = var.eks_create_kms_key == true ? 0 : 1
  key_id = var.eks_kms_key_arn
}

resource "aws_kms_key" "eks_key" {
  count = var.eks_create_kms_key == true ? 1 : 0
  description = "testkeycubes"
}

data "aws_security_group" "eks_security_group" {
  count = var.eks_create_cluster_security_group == true ? 0 : 1
  name = var.eks_security_group_name
  vpc_id = data.aws_vpc.cluster_vpc.id
}

resource "aws_security_group" "eks_security_group" {
  count = var.eks_create_cluster_security_group == true ? 1 : 0
  name        = var.eks_security_group_name # rke2-cluster-sg
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "EKS ${var.eks_cluster_name}",
    "kubernetes.io/cluster/${var.eks_cluster_name}": "owned"
  }, var.tags)
}

# resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
#   count = var.eks_create_cluster_security_group == true ? 1 : 0
#   security_group_id = one(concat(aws_security_group.eks_security_group[*].id))
#   cidr_ipv4         = data.aws_vpc.cluster_vpc.cidr_block
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
#   count = var.eks_create_cluster_security_group == true ? 1 : 0
#   security_group_id = one(concat(aws_security_group.eks_security_group[*].id))
#   cidr_ipv4         = data.aws_vpc.cluster_vpc.cidr_block
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
#   count = var.eks_create_cluster_security_group == true ? 1 : 0
#   security_group_id = one(concat(aws_security_group.eks_security_group[*].id))
#   cidr_ipv4         = data.aws_vpc.cluster_vpc.cidr_block
#   from_port         = 6443
#   ip_protocol       = "tcp"
#   to_port           = 6443
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_cluster_non_std_ipv4" {
#   count = var.eks_create_cluster_security_group == true ? 1 : 0
#   security_group_id = one(concat(aws_security_group.eks_security_group[*].id))
#   cidr_ipv4         = data.aws_vpc.cluster_vpc.cidr_block
#   from_port         = 30000
#   ip_protocol       = "tcp"
#   to_port           = 32767
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   count = var.eks_create_cluster_security_group == true ? 1 : 0
#   security_group_id = one(concat(aws_security_group.eks_security_group[*].id))
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
#   count = var.eks_create_cluster_security_group == true ? 1 : 0
#   security_group_id = one(concat(aws_security_group.eks_security_group[*].id))
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# data "aws_security_group" "eks_node_security_group" {
#   count = var.eks_create_node_security_group == true ? 0 : 1
#   name = var.eks_security_group_name
#   vpc_id = data.aws_vpc.cluster_vpc.id
# }

# resource "aws_security_group" "eks_node_security_group" {
#   count = var.eks_create_node_security_group == true ? 1 : 0
#   name        = var.eks_node_security_group_name # rke2-cluster-internal-sg
#   description = "Allow traffic"
#   vpc_id      = var.vpc_id

#   tags = merge({
#     Name = "EKS ${var.eks_cluster_name}",
#     "kubernetes.io/cluster/${var.eks_cluster_name}": "owned"
#   }, var.tags)
# }

# # I think this needs to be tightened up, not sure how far. 
# # Reference rke2-cluster-internal-sg
# resource "aws_vpc_security_group_ingress_rule" "node_allow_tls_ipv4" {
#   count = var.eks_create_node_security_group == true ? 1 : 0
#   security_group_id = one([aws_security_group.eks_node_security_group[*].id])
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1"
# }

# resource "aws_vpc_security_group_egress_rule" "node_allow_all_traffic_ipv4" {
#   count = var.eks_create_node_security_group == true ? 1 : 0
#   security_group_id = one([aws_security_group.eks_node_security_group[*].id])
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# resource "aws_vpc_security_group_egress_rule" "node_allow_all_traffic_ipv6" {
#   count = var.eks_create_node_security_group == true ? 1 : 0
#   security_group_id = one([aws_security_group.eks_node_security_group[*].id])
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# locals {
#   eks_role_arn = one([concat(
#     data.aws_iam_role.aws_k8s_role[*].arn,
#     aws_iam_role.aws_k8s_role[*].arn,
#     )])

#   eks_key_arn = one([concat(
#     data.aws_kms_key.eks_key[*].arn,
#     aws_kms_key.eks_key[*].arn,
#   )])

#   eks_security_group_id = one([concat(
#     data.aws_security_group.eks_security_group[*].id,
#     aws_security_group.eks_security_group[*].id,
#   )])

#   eks_node_security_group_id = one([
#     data.aws_security_group.eks_node_security_group[*].id,
#     aws_security_group.eks_node_security_group[*].id,
#   ])
# }

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.15.3"
#   cluster_name = var.eks_cluster_name
#   cluster_version = var.eks_cluster_version


#   # create_cni_ipv6_iam_policy = var.eks_create_cni_ipv6_iam_policy
#   create_iam_role  = false
#   iam_role_arn = local.eks_role_arn

#   create_kms_key = false
#   cluster_encryption_config = [
#     {
#       provider_key_arn = local.eks_key_arn
#       resources = ["secrets"]
#     }
#   ]

#   create_cluster_security_group = false 
#   cluster_security_group_id = local.eks_security_group_id
#   create_node_security_group = false 
#   node_security_group_id = local.eks_node_security_group_id

#   vpc_id                         = data.aws_vpc.cluster_vpc.id
#   subnet_ids                     = var.eks_subnet_ids
#   cluster_endpoint_public_access = false
#   cluster_endpoint_private_access = true
#   # cluster_additional_security_group_ids = [aws_security_group.eks.id]
#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"
#   }

#   eks_managed_node_groups = {
#     one = {
#       name = "node-group-1"
#       instance_types = var.eks_node_group_instance_types
      
#       min_size     = var.eks_node_group_min_size
#       max_size     = var.eks_node_group_max_size
#       desired_size = var.eks_node_group_desired_size
#     }

#     two = {
#       name = "node-group-2"
#       instance_types = var.eks_node_group_instance_types # ["t3.medium"]

#       min_size     = var.eks_node_group_min_size
#       max_size     = var.eks_node_group_max_size
#       desired_size = var.eks_node_group_desired_size
#     }
#   }
# }