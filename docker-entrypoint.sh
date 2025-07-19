#!/bin/bash

# Start Grafana in the background
/run.sh &
GRAFANA_PID=$!

# Wait a bit for Grafana to start (the user script will also wait for readiness)
sleep 10

# Run the viewer user creation script
/scripts/create_grafana_viewer.sh || echo "[WARN] Viewer user creation script failed."

# Run the ambassador user creation script if ambassador credentials are provided
if [[ -n "$GRAFANA_AMBASSADOR_USER" && -n "$GRAFANA_AMBASSADOR_PASSWORD" && -n "$GRAFANA_AMBASSADOR_EMAIL" ]]; then
  /scripts/create_grafana_ambassador.sh || echo "[WARN] Ambassador user creation script failed."
fi

# Wait for Grafana to exit
wait $GRAFANA_PID 