#!/bin/bash

# TODO: This should just be instructions for a quick and dirty demo on localhost 
#       after installing the prerequisites

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

# Go to https://localhost/nifi/