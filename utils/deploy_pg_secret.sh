#!/bin/bash

# Source the environment variables
source ENV.sh

# Encode the database credentials
DB_USER=$(echo -n $DATABASE_USER | base64)
DB_PASSWORD=$(echo -n $DATABASE_PASSWORD | base64)

# Create and apply the secret manifest
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secrets
type: Opaque
data:
  user: $DB_USER
  password: $DB_PASSWORD
EOF

echo "Secret 'postgres-secrets' created."
