#!/bin/bash

# Install the packages that we can get from package manager
sudo dnf update -y
sudo dnf install -y \
                git \
                docker \
                openssl

# Configure docker for the ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -a -G docker ec2-user
su - $USER # relogin to the session to absorb the user group changes

# Install Homebrew
CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/ec2-user/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install kubectl
brew install kubernetes-cli

# Install helm
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh

# Install zarf - https://www.youtube.com/watch?v=7X2znDbN4-E&t=5s
brew tap defenseunicorns/tap && brew install zarf
# zarf init - initializes cluster

# Install k3d for minimal Kubernetes to run inside docker
brew install k3d k3sup


k3d cluster create -p "443:8443@loadbalancer" --agents 2

git clone https://github.com/cetic/helm-nifi.git nifi
cd nifi
helm repo update
helm dep up
helm install nifi .
helm install
helm install nifi .
helm uninstall nifi
kubectl get nodes
nano values.yaml 
helm install nifi .
kubectl get nodes


kubectl cluster-info
helm status
helm status nifi
helm status nifi --show-resources
kubectl port-forward -n default svc/nifi 8443:8443
kubectl get pods
kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}'
kubectl port-forward -n default svc/nifi 8443:8443 &
curl -k https://localhost:8443/nifi/

TODO FOR EKS:
Set the role for which to create the cluster on the deployment VM
    This role is the one that 
Modify security groups for EKS cluster to allow 443 from deployment VM security group
