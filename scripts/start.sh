#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Grafana..."

# Set Railway-specific environment variables if not already set
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    export GF_SERVER_ROOT_URL="https://$RAILWAY_PUBLIC_DOMAIN"
    export GF_SERVER_DOMAIN="$RAILWAY_PUBLIC_DOMAIN"
fi

# Ensure proper permissions
chown -R grafana:root /var/lib/grafana || true
chown -R grafana:root /etc/grafana || true

# Start Grafana with the default command
exec /run.sh 