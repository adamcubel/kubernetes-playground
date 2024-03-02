#!/bin/bash

region=${region:-"us-east-1"}
iam_role=${iam_role:-"ec2Deploy"}
policy_filename=${policy_filename:-"trust-policy.json"}


while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
  
done

if [ $region == "" ]; then
    echo "AWS region is empty. Specify a valid region."
    echo "Exiting..."
    exit 1
fi

# Before running this script, the deployment role needs to be in AWS IAM
# and attached to this VM

# Use the basic information to get the user that is consuming the attached role on EC2
mkdir -p ~/.aws
cat > ~/.aws/config << EOF
[default]
region = $region
credential_source = Ec2InstanceMetadata
output = json
EOF

ACCOUNT_ID=$(aws sts get-caller-identity | jq --raw-output '.Account')
CALLER_IDENTITY=$(aws sts get-caller-identity | jq --raw-output '.Arn')
echo "Caller ID: \"$CALLER_IDENTITY\""

# INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_ID=$(cat /var/lib/cloud/data/instance-id)
echo "Instance ID: \"$INSTANCE_ID\""


# Create policy that allows the EC2 Instance to assume the role 
# in order to be able to deploy terraform
cat > $policy_filename << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com",
                "AWS": "$CALLER_IDENTITY"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
echo "aws iam update-assume-role-policy --role-name $iam_role --policy-document $policy_filename"
aws iam update-assume-role-policy --role-name $iam_role --policy-document file://"$policy_filename"

cat > ~/.aws/config << EOF
[default]
region = $region
credential_source = Ec2InstanceMetadata
role_arn = arn:aws:iam::$ACCOUNT_ID:role/$iam_role
output = json
EOF