#!/bin/bash

region=${region:-"us-east-1"}

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


mkdir -p ~/.aws
cat > ~/.aws/config << EOF
[default]
region = $region
credential_source = Ec2InstanceMetadata
output = json
EOF