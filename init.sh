# Description: This script is used to initialize a synapse server on Azure Kubernetes Service (AKS)
# This script will create a resource group, AKS cluster, and deploy the postgres database on the AKS cluster

# Set variables
resource_group="matrix-synapse-server"
cluster_name="matrix-synapse-cluster"
location="eastus2"
domain="synapse.alex.com"

# Login to Azure
az login

# Create a resource group
az group create --name $resource_group --location $location

# Create an AKS cluster
az aks create --resource-group $resource_group --name $cluster_name --node-count 1 --enable-addons monitoring --generate-ssh-keys

# Get the credentials for the AKS cluster
az aks get-credentials --resource-group $resource_group --name $cluster_name

# Deploy persistent volume claim for the postgres database
kubectl apply -f ./config/postgres-pvc.yaml

# Deploy the postgres database and service
kubectl apply -f ./config/postgres-deployment.yaml

# Create a configmap for the synapse server
kubectl create configmap synapse-config --from-file=homeserver.yaml=./config/homeserver.yaml

# Create a persistent volume claim for the synapse server (for media storage)
kubectl apply -f ./config/synapse-pvc.yaml

# Deploy the synapse server and service
kubectl apply -f ./config/synapse-deployment.yaml


az network dns zone create --name $domain --resource-group $resource_group

# store the external IP address of the synapse server
external_ip=$(kubectl get svc synapse -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# create an A record for the synapse server
az network dns record-set a add-record --resource-group $resource_group --zone-name $domain --record-set-name synapse --ipv4-address $external_ip



