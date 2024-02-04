# matrix-synapse-aks

Deployment of a matrix synapse server on aks. This will use sensible defaults, creates a postgres database, stores secrets in kube secrets, and sets up a recaptcha v2 check for registration.

This is significantly cheaper than running a synapse server on a cloud hosted VM, and it is easier to manage.

## Prerequisites

1. You will need a domain name and access to the DNS zone for that domain.
I chose to use Azure DNS for my domain, but you can use any DNS provider.
![domain hosting](https://github-production-user-asset-6210df.s3.amazonaws.com/36140593/302076208-9e9ad36d-17f5-42f2-84b3-6898fa0e0220.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240204%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240204T040618Z&X-Amz-Expires=300&X-Amz-Signature=c0f2e72d9e7d52215ffec17a6cadcc9349d54f5baf6c108b7224af97af583048&X-Amz-SignedHeaders=host&actor_id=36140593&key_id=0&repo_id=752121039)
The DNS and the domain live in the same resource group. We will use the resource group name for the DNS_RESOURCE_GROUP in the `ENV.sh` file.
![domain resource group](https://github-production-user-asset-6210df.s3.amazonaws.com/36140593/302076191-2cfd341d-2deb-4c2d-adda-44b5cb324d5a.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240204%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240204T040554Z&X-Amz-Expires=300&X-Amz-Signature=b8a7e5a77196a01431d769a529b569dfd72ed81e44bf0e553b7545877f85754f&X-Amz-SignedHeaders=host&actor_id=36140593&key_id=0&repo_id=752121039)

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
