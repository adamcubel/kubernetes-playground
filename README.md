# kubernetes-playground

Terraform Docker Image for deployment relies on Iron Bank Terraform Image: 
- https://ironbank.dso.mil/repomap/details;registry1Path=hashicorp%252Fterraform

The image can be pulled using the following instructions:
- https://docs-ironbank.dso.mil/tutorials/image-pull/

For simplicity, a devcontainer has been built up within this repo to allow developers simple access to Terraform.

Virtual Machine Dependencies
    AWS CLI
    git
    kubectl
    helm
    Docker/Podman (To create, host, and deploy OCI images to cluster)

Docker Images will be used for:
    IaC deployment of cluster via Terraform
    NiFi
    Zookeeper
    EAI
    Kafka

Terraform will be used to:
    Create Elastic Container Repository (ECR)
    Create Elastic Kubernetes Service (EKS) Cluster

Scripts will be used to:
    Pull all of the dependent images onto the deployment VM
    Helm pull the all application dependencies

Deployment in other is done by:
    Create VM image/backup in this of the deployment VM containing all dependencies
        This includes the docker images hosted locally on the machine
    Create VM from backup in other
        Create the necessary permissions
            https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html#vmimport-role
        Execute Terraform to stand up infrastructure
        Execute Helm to deploy pods supporting Apache NiFi
            https://repo1.dso.mil/dsop/helm-charts

Steps to create VM Image in AWS:
https://docs.aws.amazon.com/vm-import/latest/userguide/vmexport.html
https://repost.aws/knowledge-center/ami-resolve-import-export-blsc-error 
Must have S3 bucket
Must add bucket ACL for AWS


Helm will be used to create the NiFi application by provisioning nodes / pods in the cluster.


After deploying the Terraform, use the following command to configure the Kubectl 

aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
