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

# Step 1: Confirm before proceeding
echo "WARNING: This will destroy the infrastructure for the '$ENVIRONMENT' environment!"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Operation canceled."
  exit 0
fi

# Step 2: Navigate to the Terraform directory
echo "Navigating to Terraform directory for environment: $ENVIRONMENT"
cd "$TERRAFORM_DIR"

# Step 3: Destroy Terraform infrastructure
echo "Destroying Terraform infrastructure for environment: $ENVIRONMENT"
terraform init
terraform destroy -auto-approve

echo "Infrastructure for environment '$ENVIRONMENT' has been successfully destroyed!"
