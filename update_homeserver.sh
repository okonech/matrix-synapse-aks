# Description: This script is used to update the homeserver.yaml file after local 
# changes are made, and apply the changes to the synapse server.

# Prerequisites:
# - Azure CLI
# - kubectl
# - Logged into Azure CLI with 'az login'
# - Logged into the AKS cluster with 'az aks get-credentials --resource-group $resource_group --name $cluster_name'

# Delete the existing configmap and create a new one with the updated homeserver.yaml file
kubectl delete configmap synapse-config
kubectl create configmap synapse-config --from-file=homeserver.yaml=./config/homeserver.yaml

# Restart the synapse server pod to apply the changes
# Deleting the pod will cause it to be recreated with the updated configmap
# Note: This will cause a brief downtime for the synapse server
kubectl delete pod -l app=synapse
