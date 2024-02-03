# Description: This script is used to initialize the a synapse server on Azure Kubernetes Service (AKS)
az login
# Create a resource group
az group create --name matrix-synapse-server --location eastu
# Create an AKS cluster
az aks create --resource-group matrix-synapse-server --name matrix-synapse-cluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
# Get the credentials for the AKS cluster
az aks get-credentials --resource-group matrix-synapse-server --name matrix-synapse-cluster

# Deploy persistent volume and persistent volume claim for the postgres database
kubectl apply -f postgres-pvc.yaml
# Deploy the postgres database and service
kubectl apply -f postgres-deployment.yaml



