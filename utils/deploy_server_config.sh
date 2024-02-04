#!/bin/bash

# Source the environment variables
source ENV.sh
# Check if the SYNAPSE_SERVER_NAME variable is set
if [ -z "$SYNAPSE_SERVER_NAME" ]; then
  echo "SYNAPSE_SERVER_NAME environment variable is not set."
  exit 1
fi

# Generate the ConfigMap using the environment variable
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: synapse-server-config
data:
  SYNAPSE_SERVER_NAME: "$SYNAPSE_SERVER_NAME"
EOF

echo "ConfigMap for $SYNAPSE_SERVER_NAME created and applied."
