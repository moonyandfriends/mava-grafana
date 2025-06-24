#!/bin/bash

# Start Grafana in the background
/run.sh &
GRAFANA_PID=$!

# Wait a bit for Grafana to start (the user script will also wait for readiness)
sleep 10

# Run the viewer user creation script
/scripts/create_grafana_viewer.sh || echo "[WARN] Viewer user creation script failed."

# Wait for Grafana to exit
wait $GRAFANA_PID 