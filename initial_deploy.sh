# Description: This script is used to initialize a synapse server on Azure Kubernetes Service (AKS)
# This script will create a resource group, AKS cluster, DNS zone, and deploy the postgres database on the AKS cluster.
# It will also deploy the synapse server and create an A record for the synapse server in the DNS zone.

# Prerequisites:
# - Azure CLI
# - kubectl
# - Logged into Azure CLI with 'az login'

# Set variables
dns_resource_group="domain-hosting"
resource_group="matrix-synapse-server"
cluster_name="matrix-synapse-cluster"
location="eastus2"
domain="okonech.net"

# Create a resource group
az group create --name $resource_group --location $location

# Create an AKS cluster
az aks create --resource-group $resource_group --name $cluster_name --node-count 2 --enable-addons monitoring --generate-ssh-keys

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

# Create an nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Install cert-manager CRDs
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.crds.yaml

# Install cluster issuer for Let's Encrypt
kubectl apply -f ./config/letsencrypt-issuer.yaml

# Deploy the ingress for the synapse server
kubectl apply -f ./config/synapse-ingress.yaml

# store the external IP address of the synapse server
external_ip=$(kubectl get svc synapse -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# store the external IP address of the ingress controller
ingress_external_ip=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# create an A record for the synapse server
az network dns record-set a add-record --resource-group $resource_group --zone-name $domain --record-set-name synapse --ipv4-address $external_ip

# Create an A record for the ingress controller
az network dns record-set a add-record --resource-group $resource_group --zone-name $domain --record-set-name nginx-ingress --ipv4-address $ingress_external_ip



