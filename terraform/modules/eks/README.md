This module is sourced from: https://github.com/aws-samples/private-eks-for-windows-workloads-with-terraform/tree/main/eks/cluster

The parent link to the repository is: https://github.com/aws-samples/private-eks-for-windows-workloads-with-terraform

TODO: 
    Cleanup the module so that we only have the necessary components here. 
    Ensure that the network is setup properly before deploying the EKS private cluster so that peering is in-place
        This will allow us to connect to the cluster after provisioning using kubectl
    Finally we need to make sure that the entire deployment can be done within an air-gapped environment