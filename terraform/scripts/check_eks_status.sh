#!/bin/bash

# Check EKS Cluster Status
aws eks describe-cluster --name team3-library-cluster --region us-west-2

# Check Node Group Status
aws eks describe-nodegroup --cluster-name team3-library-cluster --nodegroup-name team3-library-node-group --region us-west-2

# List Nodes in the Cluster
kubectl get nodes

# Check Pods Status
kubectl get pods --namespace team3
