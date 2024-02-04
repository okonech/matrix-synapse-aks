#!/bin/bash

# Source the environment variables
source ENV.sh

# Create the Ingress resource from a template
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: synapse-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  rules:
  - host: $SYNAPSE_SERVER_NAME
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: synapse
            port:
              number: 80
  tls:
  - hosts:
    - $SYNAPSE_SERVER_NAME
    secretName: synapse-tls-cert
EOF

echo "Ingress for $SYNAPSE_SERVER_NAME created and applied."
