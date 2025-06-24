#!/bin/sh

# Debug: Print environment variables (without sensitive data)
echo "🚀 Starting Grafana with configuration:"
echo "   PORT: ${PORT:-3000}"
echo "   GRAFANA_ADMIN_USER: ${GRAFANA_ADMIN_USER:-admin}"
echo "   RAILWAY_PUBLIC_DOMAIN: ${RAILWAY_PUBLIC_DOMAIN:-not-set}"
echo "   GF_SERVER_HTTP_PORT: ${GF_SERVER_HTTP_PORT:-3000}"

# Check if required directories exist
echo "📁 Checking directories..."
ls -la /var/lib/grafana/
ls -la /etc/grafana/

# Start Grafana with Railway-compatible settings
exec grafana-server \
    --config=/etc/grafana/grafana.ini \
    --homepath=/usr/share/grafana \
    --pidfile=/var/run/grafana/grafana.pid \
    --packaging=docker 