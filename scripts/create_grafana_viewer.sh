#!/bin/bash
#
# create_grafana_viewer.sh
#
# Creates a non-admin (Viewer) Grafana user using the Grafana HTTP API.
# Intended for use in CI/CD (e.g., Railway) or Docker environments.
#
# Required environment variables:
#   GRAFANA_URL (default: http://localhost:3000)
#   GRAFANA_ADMIN_USER (default: admin)
#   GRAFANA_ADMIN_PASSWORD (default: admin)
#   GRAFANA_VIEWER_USER (required)
#   GRAFANA_VIEWER_PASSWORD (required)
#   GRAFANA_VIEWER_EMAIL (required)
#
# Example usage:
#   GRAFANA_VIEWER_USER=viewer GRAFANA_VIEWER_PASSWORD=secret GRAFANA_VIEWER_EMAIL=viewer@example.com ./scripts/create_grafana_viewer.sh

set -e

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:-admin}"
GRAFANA_VIEWER_USER="${GRAFANA_VIEWER_USER}"
GRAFANA_VIEWER_PASSWORD="${GRAFANA_VIEWER_PASSWORD}"
GRAFANA_VIEWER_EMAIL="${GRAFANA_VIEWER_EMAIL}"

if [[ -z "$GRAFANA_VIEWER_USER" || -z "$GRAFANA_VIEWER_PASSWORD" || -z "$GRAFANA_VIEWER_EMAIL" ]]; then
  echo "Error: GRAFANA_VIEWER_USER, GRAFANA_VIEWER_PASSWORD, and GRAFANA_VIEWER_EMAIL must be set."
  exit 1
fi

# Wait for Grafana to be ready
MAX_RETRIES=30
RETRY_DELAY=2
RETRIES=0
until curl -s -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" "$GRAFANA_URL/api/health" | grep 'database'; do
  RETRIES=$((RETRIES+1))
  if [ $RETRIES -ge $MAX_RETRIES ]; then
    echo "Grafana did not become ready in time. Exiting."
    exit 1
  fi
  echo "Waiting for Grafana to be ready... ($RETRIES/$MAX_RETRIES)"
  sleep $RETRY_DELAY
done

echo "Grafana is ready. Creating viewer user..."

# Create the user (default role is Viewer)
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$GRAFANA_URL/api/admin/users" \
  -H "Content-Type: application/json" \
  -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" \
  -d "{\"name\": \"$GRAFANA_VIEWER_USER\", \"email\": \"$GRAFANA_VIEWER_EMAIL\", \"login\": \"$GRAFANA_VIEWER_USER\", \"password\": \"$GRAFANA_VIEWER_PASSWORD\"}")

HTTP_BODY=$(echo "$RESPONSE" | head -n -1)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "201" ]]; then
  echo "Viewer user '$GRAFANA_VIEWER_USER' created successfully."
else
  echo "Failed to create user. HTTP status: $HTTP_STATUS"
  echo "Response body: $HTTP_BODY"
  exit 1
fi 