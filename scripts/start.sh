#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Grafana..."

# If Railway injected $PORT, use it for Grafana
if [ -n "$PORT" ]; then
    export GF_SERVER_HTTP_PORT="$PORT"
    echo "   Using Railway PORT: $PORT"
fi

# Set Railway-specific environment variables if not already set
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    export GF_SERVER_ROOT_URL="https://$RAILWAY_PUBLIC_DOMAIN"
    export GF_SERVER_DOMAIN="$RAILWAY_PUBLIC_DOMAIN"
    echo "   Using Railway domain: $RAILWAY_PUBLIC_DOMAIN"
fi

# Check if Supabase environment variables are set
if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_SERVICE_KEY" ]; then
    echo "   Supabase configuration detected"
else
    echo "   Supabase configuration not found - using TestData as default"
fi

# Ensure proper permissions
echo "   Setting file permissions..."
chown -R grafana:root /var/lib/grafana || true
chown -R grafana:root /etc/grafana || true

echo "   Starting Grafana server..."
# Start Grafana with the correct command
exec grafana-server \
     --homepath=/usr/share/grafana \
     --config=/etc/grafana/grafana.ini \
     --pidfile=/var/run/grafana/grafana-server.pid 