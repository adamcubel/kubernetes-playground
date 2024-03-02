#!/bin/bash

# Start with amazonlinux or RHEL 9 VM
# TODO: Add a switch that the caller can use to flip back and forth

# Install the packages that we can get from DNF package manager
sudo dnf update -y
sudo dnf install -y \
                git \
                unzip \
                nano \
                jq
sudo dnf groupinstall -y 'Development Tools'

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Docker on Amazon Linux
sudo dnf install -y docker

# ... or Install Docker for RHEL9
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure docker for the ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -a -G docker ec2-user

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

# Install k3d for minimal Kubernetes to run inside docker
brew install k3d k3sup

# Install zarf - https://www.youtube.com/watch?v=7X2znDbN4-E&t=5s
# brew tap defenseunicorns/tap && brew install zarf
# zarf init - initializes cluster