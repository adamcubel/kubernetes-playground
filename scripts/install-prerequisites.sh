#!/bin/bash

# Start with RHEL 9 VM



# Install the packages that we can get from DNF package manager
sudo dnf update -y
sudo dnf install -y \
                git \
                unzip \
                nano
sudo dnf groupinstall -y 'Development Tools'

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# systemctl --user enable --now podman.socket
# or podman system service --time=0
# XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
# export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock

# Install Docker on Amazon Linux
sudo dnf install -y docker

# Install Docker for RHEL9
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure docker for the ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -a -G docker ec2-user
# su - $USER # relogin to the session to absorb the user group changes

# Install Homebrew
CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/ec2-user/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install Terraform
brew install terraform

# Install kubectl
brew install kubernetes-cli

# Install helm
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh && rm /tmp/get_helm.sh

# Install zarf - https://www.youtube.com/watch?v=7X2znDbN4-E&t=5s
# brew tap defenseunicorns/tap && brew install zarf
# zarf init - initializes cluster

# Install k3d for minimal Kubernetes to run inside docker
brew install k3d k3sup

# Creating the Kubernetes cluster locally using k3d
k3d cluster create -p "443:8443@loadbalancer" --agents 2
kubectl cluster-info

# Create the NiFi Application in the cluster
git clone https://github.com/adamcubel/kubernetes-playground.git
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add dysnix https://dysnix.github.io/charts/
cd helm/nifi
helm repo update
helm dep up
helm install nifi .

# Troubleshooting commands
kubectl get nodes
kubectl get pods
helm status nifi --show-resources

# Forwarding and testing status
kubectl port-forward -n default svc/nifi 8443:8443 &
curl -k https://localhost:8443/nifi/

# Exporting the VM
{
    "ContainerFormat": "ova",
    "DiskImageFormat": "VMDK",
    "S3Bucket": "cubel-bucket-1234",
    "S3Prefix": "vms/"
}


# TODO: Take these export commands and put them into a separate script
cat > ./file.json << EOF
{
    "ContainerFormat": "ova",
    "DiskImageFormat": "VMDK",
    "S3Bucket": "cubel-bucket-1234",
    "S3Prefix": "vms/"
}
EOF
aws ec2 create-instance-export-task --instance-id <instance ID> --target-environment vmware --export-to-s3-task file://"file.json"

# TODO FOR EKS:
# Set the role for which to create the cluster on the deployment VM
#    This role is the one that Modify security groups for EKS cluster to allow 443 from deployment VM security group
