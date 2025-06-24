#!/bin/sh

# Debug: Print environment variables (without sensitive data)
echo "🚀 Starting Grafana with configuration:"
echo "   PORT: ${PORT:-not-set}"
echo "   GF_SERVER_HTTP_PORT: ${GF_SERVER_HTTP_PORT:-3000}"
echo "   GRAFANA_ADMIN_USER: ${GRAFANA_ADMIN_USER:-admin}"
echo "   RAILWAY_PUBLIC_DOMAIN: ${RAILWAY_PUBLIC_DOMAIN:-not-set}"

# If Railway injected $PORT, use it
if [ -n "$PORT" ]; then
    export GF_SERVER_HTTP_PORT="$PORT"
    echo "   Using Railway PORT: $PORT"
else
    echo "   Using default PORT: 3000"
fi

# Check if required files exist
echo "📁 Checking required files..."
if [ -f "/etc/grafana/grafana.ini" ]; then
    echo "   ✓ grafana.ini found"
else
    echo "   ✗ grafana.ini not found!"
    exit 1
fi

if [ -d "/usr/share/grafana" ]; then
    echo "   ✓ homepath directory exists"
else
    echo "   ✗ homepath directory not found!"
    exit 1
fi

echo "🚀 Starting Grafana server..."
exec grafana-server \
     --homepath=/usr/share/grafana \
     --config=/etc/grafana/grafana.ini 