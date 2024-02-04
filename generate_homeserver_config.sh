#!/bin/bash

# Source environment variables
source ./ENV.sh

# Use environment variables in the configuration
cat > ./tmp/homeserver.yaml << EOF
version: 1
server_name: "${SYNAPSE_SERVER_NAME}"
pid_file: /data/homeserver.pid

listeners:
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    # Must accept all local connections in a kubernetes environment. ['::1', '127.0.0.1'] is only for a local machine environment.
    bind_addresses: ['0.0.0.0']
    resources:
      - names: [client, federation]
        compress: false

database:
  name: psycopg2
  args:
    user: ${DATABASE_USER}
    password: ${DATABASE_PASSWORD}
    database: synapsedb
    host: postgres
    port: 5432
    cp_min: 5
    cp_max: 10

media_store_path: /data/media_store

# Logging settings - only log to console and not to any file
formatters:
  precise:
    format: '%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(request)s - %(message)s'
handlers:
  console:
    class: logging.StreamHandler
    formatter: precise
loggers:
    synapse.storage.SQL:
        # beware: increasing this to DEBUG will make synapse log sensitive
        # information such as access tokens.
        level: INFO
root:
    level: INFO
    handlers: [console]
disable_existing_loggers: false

# Path where signed keys will be stored
signing_key_path: "/data/${SYNAPSE_SERVER_NAME}.signing.key"

# Key used to sign bearer tokens (macaroons)
macaroon_secret_key: "${MACAROON_SECRET_KEY}"

# Suppress key server warning because we are using a trusted key server already
suppress_key_server_warning: true

trusted_key_servers:
  - server_name: "matrix.org"

# Disable telemetry reporting
report_stats: false

# Enable registration for users
enable_registration: true

# This allows registrations only from those who know the secret or where the secret is used in a custom registration form.
registration_shared_secret: "${REGISTRATION_SHARED_SECRET}"

# ReCaptchav2 settings
enable_registration_captcha: true
recaptcha_public_key: "${RECAPTCHA_PUBLIC_KEY}"
recaptcha_private_key: "${RECAPTCHA_PRIVATE_KEY}"
EOF

echo "Homeserver configuration generated."