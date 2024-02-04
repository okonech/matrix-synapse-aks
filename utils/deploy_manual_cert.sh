#!/bin/bash

# Source the environment variables
source ENV.sh

# Generate and apply the Certificate manifest
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: synapse-manual-cert
  namespace: default
spec:
  secretName: synapse-tls-cert
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  dnsNames:
  - ${SYNAPSE_SERVER_NAME}
EOF

echo "Certificate for ${SYNAPSE_SERVER_NAME} deployed."