#!/bin/bash
set -e

# Start health check server in the background
python3 /healthz.py &

# Start Grafana as usual
exec /usr/local/bin/start.sh 