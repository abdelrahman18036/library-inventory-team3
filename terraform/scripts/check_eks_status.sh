#!/bin/bash

$profile = "orange"
$region = "us-west-2"

# Check EKS Cluster Status
aws eks describe-cluster --name team3-library-cluster --region $region --profile $profile

# Check Node Group Status
aws eks describe-nodegroup --cluster-name team3-library-cluster --nodegroup-name team3-library-node-group --region $region --profile $profile

# Update kubeconfig
aws eks update-kubeconfig --name team3-library-cluster --region $region --profile $profile

# List Nodes in the Cluster
kubectl get nodes

# Check Pods Status
kubectl get pods --namespace team3

# Check Services Status
kubectl get services --namespace team3

# Check Ingress Status
kubectl get svc team3-library-inventory-service --namespace team3



