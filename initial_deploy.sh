# Description: This script is used to initialize a synapse server on Azure Kubernetes Service (AKS)
# This script will create a resource group, AKS cluster, DNS zone, and deploy the postgres database on the AKS cluster.
# It will also deploy the synapse server and create an A record for the synapse server in the DNS zone.

# Prerequisites:
# - Azure CLI
# - kubectl
# - curl
# - Logged into Azure CLI with 'az login'

# Source environment variables
source ./ENV.sh

# Create a resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create an AKS cluster
az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --enable-addons monitoring --generate-ssh-keys

# Get the credentials for the AKS cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Deploy storage class for the persistent volume claims to persist data
kubectl apply -f ./config/storage-class-def.yaml

# Deploy persistent volume claim for the postgres database
kubectl apply -f ./config/postgres-pvc.yaml

# Deploy the postgres secret
./utils/deploy_pg_secret.sh

# Deploy the postgres database and service
kubectl apply -f ./config/postgres-deployment.yaml

# Generate a homeserver.yaml file using the environment variables
./utils/generate_homeserver_config.sh

# Create a configmap for the synapse server
kubectl create configmap synapse-config --from-file=homeserver.yaml=./tmp/homeserver.yaml

# Deploy the configmap for the synapse server settings (server name, etc.)
./utils/deploy_synapse_ingress.sh

# Create a persistent volume claim for the synapse server (for media storage)
kubectl apply -f ./config/synapse-pvc.yaml

# Deploy the synapse server and service
kubectl apply -f ./config/synapse-deployment.yaml

# Create an nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Find and install the latest version of cert-manager
./utils/install_latest_cert-manager.sh

# Install cluster issuer for Let's Encrypt
kubectl apply -f ./config/letsencrypt-issuer.yaml

# Deploy the ingress for the synapse server
./utils/deploy_synapse_ingress.sh

# store the external IP address of the ingress controller
ingress_external_ip=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Create an A record for the ingress controller
az network dns record-set a add-record --resource-group $DNS_RESOURCE_GROUP --zone-name $DOMAIN --record-set-name synapse --ipv4-address $ingress_external_ip



