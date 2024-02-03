# Description: This script is used to fully uninstall and reinstall cert-manager on an AKS cluster.
# All resources created by cert-manager will be deleted, and then cert-manager will be reinstalled.
# This is useful to upgrade cert-manager to a much newer version, or to fix issues with the current installation.
# This will remove all certificates and issuers, so there will be downtime for any services using Let's Encrypt.


# Prerequisites:
# - Azure CLI
# - kubectl
# - curl
# - Logged into Azure CLI with 'az login'
# - Logged into the AKS cluster with 'az aks get-credentials --resource-group $resource_group --name $cluster_name'

# Delete all resources created by cert-manager
kubectl delete certificates --all -A
kubectl delete certificaterequests --all -A
kubectl delete orders --all -A
kubectl delete challenges --all -A
kubectl delete issuers --all -A
kubectl delete clusterissuers --all -A

# Delete the cert-manager namespace
kubectl delete namespace cert-manager

# Delete the cert-manager CRDs
kubectl delete crd -l app.kubernetes.io/name=cert-manager

# Clean up any remaining cert-manager resources
crd_names=$(kubectl get crds | grep cert-manager.io)
kubectl delete crd $crd_names
pod_names=$(kubectl get pods --all-namespaces | grep cert-manager)
kubectl delete pods $pod_names


# Find and install the latest version of cert-manager
./utils/install_latest_cert-manager.sh

