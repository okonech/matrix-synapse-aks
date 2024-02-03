#!/bin/bash

# Set the GitHub repository
REPO="cert-manager/cert-manager"

# Fetch the latest release tag from GitHub
LATEST_RELEASE_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

# Check if we got a tag
if [ -z "$LATEST_RELEASE_TAG" ]; then
    echo "Failed to fetch the latest cert-manager release tag from GitHub."
    exit 1
fi

echo "Latest cert-manager release: $LATEST_RELEASE_TAG"

# Define the URLs for CRDs and the main YAML
CRD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE_TAG/cert-manager.crds.yaml"
CERT_MANAGER_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE_TAG/cert-manager.yaml"

# Apply the CRDs
echo "Applying CRDs..."
kubectl apply -f "$CRD_URL"

# Check for the cert-manager namespace and create if not exists
kubectl get namespace cert-manager >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Creating namespace: cert-manager"
    kubectl create namespace cert-manager
else
    echo "Namespace cert-manager already exists"
fi

# Apply the main cert-manager YAML
echo "Deploying cert-manager..."
kubectl apply -f "$CERT_MANAGER_URL"

echo "Cert-manager deployment initiated. Please check the cert-manager namespace for pod status."
