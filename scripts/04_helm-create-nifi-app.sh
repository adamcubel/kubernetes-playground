#!/bin/bash

# Following the general guide available here: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

env=${env:-"low"}
vars_file=${vars_file:-"./env/low/cloudguru.tfvars"}
type=${type:-"install"}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

set -x
pushd ../terraform
cluster_region=$(terraform output -raw region)
cluster_name=$(terraform output -raw cluster_name)
cluster_vpc=$(aws eks describe-cluster --name $cluster_name | jq --raw-output '.cluster.resourcesVpcConfig.vpcId')

aws eks --region $cluster_region update-kubeconfig --name $cluster_name
popd

if [[ "$env" == "low" ]]; then
    # Login to Iron Bank OCI Repository
    # Will be prompted for username and password
    # Instructions for getting an iron bank account are here: 
    # https://docs-ironbank.dso.mil/quickstart/consumer-onboarding/
    sudo docker login registry1.dso.mil
    sudo docker pull registry1.dso.mil/ironbank/opensource/apache/nifi:1.25.0
    sudo docker pull registry1.dso.mil/ironbank/bitnami/zookeeper:3.9.1

    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
else
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy_us-gov.json 
fi

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://\"iam_policy.json\"

oidc_id=$(aws eks describe-cluster --name "$cluster_name" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

# # Troubleshooting step to ensure OIDC ID is created with the cluster. If one is not created,
# # follow the instructions here: https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# # aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4

account_id=$(aws sts get-caller-identity | jq --raw-output '.Account')
oidc_arn=$(aws iam list-open-id-connect-providers | jq --raw-output '.OpenIDConnectProviderList[0].Arn')
cat > load-balancer-role-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "$oidc_arn"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.$cluster_region.amazonaws.com/id/$oidc_id:aud": "sts.amazonaws.com",
                    "oidc.eks.$cluster_region.amazonaws.com/id/$oidc_id:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

aws iam create-role --role-name AmazonEKSLoadBalancerControllerRole --assume-role-policy-document file://\"load-balancer-role-trust-policy.json\"

aws iam attach-role-policy --policy-arn arn:aws:iam::$account_id:policy/AWSLoadBalancerControllerIAMPolicy --role-name AmazonEKSLoadBalancerControllerRole

if [[ "$env" == "low" ]]; then
cat > aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$account_id:role/AmazonEKSLoadBalancerControllerRole
EOF
else
cat > aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws-us-gov:iam::$account_id:role/AmazonEKSLoadBalancerControllerRole
EOF
fi

kubectl apply -f aws-load-balancer-controller-service-account.yaml

if [[ "$env" == "low" ]]; then
  # TODO: Parameterize the version of the load balancer
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update eks
fi

# run helm 'upgrade' rather than helm 'install' if this is an upgrade
if [[ "$type" == "install" ]]; then
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set region=$cluster_region \
    --set vpcId=$cluster_vpc \
    --set clusterName=$cluster_name \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller 
else
    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"

    helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set region=$cluster_region \
    --set vpcId=$cluster_vpc \
    --set clusterName=$cluster_name \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller 
fi

# Troubleshooting command to see if/that controller is installed
# kubectl get deployment -n kube-system aws-load-balancer-controller

cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "$oidc_arn"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.$cluster_region.amazonaws.com/id/$oidc_id:aud": "sts.amazonaws.com",
          "oidc.eks.$cluster_region.amazonaws.com/id/$oidc_id:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name AmazonEKS_EBS_CSI_DriverRole --assume-role-policy-document file://\"trust-policy.json\"

aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --role-name AmazonEKS_EBS_CSI_DriverRole

aws eks create-addon \
 --cluster-name $cluster_name \
 --addon-name aws-ebs-csi-driver \
 --service-account-role-arn arn:aws:iam::$account_id:role/AmazonEKS_EBS_CSI_DriverRole

# aws eks describe-addon-versions --addon-name aws-ebs-csi-driver

# Create the AWS EBS Storage Class
cat <<EOF > storage-class.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: aws-pg-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4 
EOF
kubectl create -f storage-class.yaml

# Remove the original default storage class so pods can make Persistent Volume Claims
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# pushd ../helm/nifi
# helm repo add cetic https://cetic.github.io/helm-charts
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo add dysnix https://dysnix.github.io/charts/
# helm repo update

# helm install -f values.yaml nifi-sisyphus cetic/nifi
# zarf init
# popd

set +x