# matrix-synapse-aks

Deployment of a matrix synapse server on aks. This will use sensible defaults, creates a postgres database, stores secrets in kube secrets, and sets up a recaptcha v2 check for registration.

This is significantly cheaper than running a synapse server on a cloud hosted VM, and it is easier to manage.

## Prerequisites

1. You will need a domain name and access to the DNS zone for that domain.
I chose to use Azure DNS for my domain, but you can use any DNS provider.

![domain hosting](https://github.com/okonech/matrix-synapse-aks/assets/36140593/925fd9cd-a7f6-4cf7-b2b1-9fe775ef8ba7)
The DNS and the domain live in the same resource group. We will use the resource group name for the DNS_RESOURCE_GROUP in the `ENV.sh` file.
![domain resource group](https://github.com/okonech/matrix-synapse-aks/assets/36140593/051852dd-2fe1-4917-91a4-e3f64b00fa4a)

1. You will need an Azure subscription and access to create resources in that subscription.
2. You will need to have the following tools installed:
   - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
   - [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
   - [curl](https://curl.se/download.html)

## Deployment steps

Create a file at the top level of the repository called 'ENV.sh' with the following content, edited for your environment and preferences:

```bash
# Description: Environment variables for the deployment
# DO NOT check this file into version control

# Domain name
export SYNAPSE_SERVER_NAME="[synapse server name (e.g. synapse.okonech.net)]"

# AKS Setup names
export DNS_RESOURCE_GROUP="[resource group for the DNS zone where your domain is hosted]"
export RESOURCE_GROUP="[resource group for the AKS cluster and other synapse resources]"
export CLUSTER_NAME="[name of the AKS cluster]"
export LOCATION="[location of the AKS cluster (e.g. eastus2)]"

# Domain for the created DNS zone
export DOMAIN="[domain name]"

# Database connection information
export DATABASE_USER="[database user for the postgres database synapse will use]"
export DATABASE_PASSWORD="[password for the postgres database synapse will use]"

# Key used to sign bearer tokens (macaroons)
# Generated with `openssl rand -base64 32`
export MACAROON_SECRET_KEY="[base64 encoded 32 byte key]"

# Generated with `openssl rand -base64 32`
export REGISTRATION_SHARED_SECRET="[base64 encoded 32 byte key]"

# Recaptcha v2 keys (for the 'are you a robot' check)
export RECAPTCHA_PUBLIC_KEY="[recaptcha public site key]"
export RECAPTCHA_PRIVATE_KEY="[recaptcha private key]"
```

Run the `initial_deploy.sh` script to create the AKS cluster and the other resources needed for the synapse server.
This script will take a while to run, as it creates the AKS cluster and the other resources needed for the synapse server.
All necessary resources will be created in the resource group specified in the `ENV.sh` file.
Sensible defaults are used for the AKS cluster, but you can change them in the configuration files if you want.

## Example ENV.sh from my test environment

All secrets included in this file are fake and should be replaced with your own.

```bash
# Description: Environment variables for the deployment
# DO NOT check this file into version control

# Domain name
export SYNAPSE_SERVER_NAME="synapse.okonech.net"

# AKS Setup names
export DNS_RESOURCE_GROUP="domain-hosting"
export RESOURCE_GROUP="matrix-synapse-server-rg"
export CLUSTER_NAME="matrix-synapse-cluster"
export LOCATION="eastus2"

# Domain for the created DNS zone
export DOMAIN="okonech.net"

# Database connection information
export DATABASE_USER="synapseuser"
export DATABASE_PASSWORD="synapsepassword"

# Key used to sign bearer tokens (macaroons)
# Generated with `openssl rand -base64 32`
export MACAROON_SECRET_KEY="lJGc4DDd+AM8x5ho34WcJ2//dc/wLS5IJGlx7XsA/K8="

# Generated with `openssl rand -base64 32`
export REGISTRATION_SHARED_SECRET="m8k/rUrZd3KEc68CS9b6zHA15nT1vjHhnamDY/refLo="

# Recaptcha v2 keys (for the 'are you a robot' check)
export RECAPTCHA_PUBLIC_KEY="xxxxxx"
export RECAPTCHA_PRIVATE_KEY="yyyyy"
```

## Troubleshooting

Sometimes the initial deployment script will show errors such as

```bash
Error from server (InternalError): error when creating "./config/letsencrypt-issuer.yaml": Internal error occurred: failed calling webhook "webhook.cert-manager.io": failed to call webhook: Post "https://cert-manager-webhook.cert-manager.svc:443/validate?timeout=30s": no endpoints available for service "cert-manager-webhook"
Error from server (InternalError): error when creating "./config/synapse-ingress.yaml": Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": failed to call webhook: Post "https://ingress-nginx-controller-admission.ingress-nginx.svc:443/networking/v1/ingresses?timeout=10s": no endpoints available for service "ingress-nginx-controller-admission"
```

which will result in a self signed certificate being used for the synapse server. This is not ideal. To fix this, you will want to run:

```bash
# fully uninstall and reinstall cert-manager
./cert-manager_full_reinstall.sh
# reinstall issuer due to creation error
kubectl apply -f ./config/letsencrypt-issuer.yaml
# Redeploy ingress to use the new issuer
./utils/deploy_synapse_ingress.sh
# (Optional) manually create a certificate for the synapse server
./utils/deploy_manual_cert.sh
```

Which will delete the cert-manager resources and reinstall them, redeploy the issuer, then redeploy the ingress to use the new issuer.
