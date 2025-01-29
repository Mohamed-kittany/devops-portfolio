#!/bin/bash

set -e

# Input: Specify the environment
ENVIRONMENT=$1
if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "Environment must be one of: dev, staging, prod"
  exit 1
fi

# Validate environment
if [[ ! -d "environments/$ENVIRONMENT" ]]; then
  echo "Error: Environment '$ENVIRONMENT' does not exist in the 'environments' directory."
  exit 1
fi

# Variables
TERRAFORM_DIR="environments/$ENVIRONMENT"
ARGOCD_NAMESPACE="argocd"
ARGOCD_REPO="git@github.com:your-repo/your-repo.git"
APP_OF_APPS_PATH="infra-app-of-apps"
SECRET_NAME="argocd-login-pass"

# Step 1: Initialize and apply Terraform for the specified environment
echo "Running Terraform for environment: $ENVIRONMENT"
cd "$TERRAFORM_DIR"
terraform init
terraform apply -auto-approve

# Step 2: Extract Terraform outputs dynamically
echo "Extracting Terraform outputs for environment: $ENVIRONMENT"
VPC_ID=$(terraform output -raw vpc_id)
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
AWS_REGION=$(terraform output -raw region)

if [ -z "$VPC_ID" ] || [ -z "$EKS_CLUSTER_NAME" ] || [ -z "$AWS_REGION" ]; then
  echo "Failed to retrieve required Terraform outputs. Exiting."
  exit 1
fi

echo "Terraform Outputs:"
echo "VPC_ID: $VPC_ID"
echo "EKS_CLUSTER_NAME: $EKS_CLUSTER_NAME"
echo "AWS_REGION: $AWS_REGION"

# Step 3: Configure kubectl for EKS cluster
echo "Updating kubeconfig for EKS cluster..."
aws eks --region "$AWS_REGION" update-kubeconfig --name "$EKS_CLUSTER_NAME"

# Step 4: Deploy ArgoCD
echo "Deploying ArgoCD to the cluster..."
kubectl create namespace "$ARGOCD_NAMESPACE" || echo "Namespace $ARGOCD_NAMESPACE already exists."
kubectl apply -n "$ARGOCD_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --namespace "$ARGOCD_NAMESPACE" \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=argocd-server \
  --timeout=300s

# Step 5: Change ArgoCD admin password
echo "Changing ArgoCD admin password..."
NEW_PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text)
INITIAL_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

argocd login --username admin \
  --password "$INITIAL_PASSWORD" \
  --grpc-web \
  --insecure \
  --server "argocd-server.$ARGOCD_NAMESPACE.svc.cluster.local"

argocd account update-password \
  --current-password "$INITIAL_PASSWORD" \
  --new-password "$NEW_PASSWORD"

# Step 6: Deploy App-of-Apps with ArgoCD
echo "Deploying App-of-Apps application..."
argocd app create app-of-apps \
  --repo "$ARGOCD_REPO" \
  --path "$APP_OF_APPS_PATH" \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace "$ARGOCD_NAMESPACE" \
  --revision main

argocd app sync app-of-apps

echo "Setup for environment '$ENVIRONMENT' complete!"
