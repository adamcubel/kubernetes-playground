#!/bin/bash

# This is nothing but a wrapper for Terraform to be able to run all of the commands 
# necessary to pull down the dependent providers locally, and create the cluster on 
# your behalf. NOTE: You will still need to create a .tfvars file that contains all
# the variables that the Terraform IaC expects

vars_file=${vars_file:-"./env/low/cloudguru.tfvars"}
env=${env:-"low"}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

pushd ../terraform

terraform init

if ["$env" -eq "low"]; then
mkdir -p ~/terraform_providers
terraform providers mirror ~/terraform_providers
fi

# TODO: Make sure in the air gap that no attempt to pull down modules happens
terraform apply -vars-file="$vars_file" -auto-approve -input=false

aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)

popd