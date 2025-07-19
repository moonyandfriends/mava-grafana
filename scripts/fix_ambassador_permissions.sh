#!/bin/bash
#
# fix_ambassador_permissions.sh
#
# Fixes existing ambassador user permissions to restrict access to only the ambassador dashboard.
# This script should be run if ambassador users currently have access to all dashboards.
#
# Required environment variables:
#   GRAFANA_URL (default: http://localhost:3000)
#   GRAFANA_ADMIN_USER (default: admin)
#   GRAFANA_ADMIN_PASSWORD (default: admin)
#
# Example usage:
#   ./scripts/fix_ambassador_permissions.sh

set -e

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed. Please install curl to use this script."
  exit 1
fi

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:-admin}"

echo "[INFO] Fixing ambassador permissions at $GRAFANA_URL ..."

# Step 1: Find the Ambassadors team
echo "[INFO] Finding Ambassadors team..."
TEAMS_RESPONSE=$(curl -s -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" "$GRAFANA_URL/api/teams/search?name=Ambassadors")
TEAM_ID=$(echo "$TEAMS_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [[ -z "$TEAM_ID" ]]; then
  echo "[ERROR] Ambassadors team not found. Please create ambassador users first using create_grafana_ambassador.sh"
  exit 1
fi

echo "[INFO] Found Ambassadors team with ID: $TEAM_ID"

# Step 2: Get all dashboards and set permissions
echo "[INFO] Finding all dashboards to set permissions..."
DASHBOARDS_RESPONSE=$(curl -s -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" "$GRAFANA_URL/api/search?type=dash-db")

# Find the ambassador dashboard
AMBASSADOR_DASHBOARD_UID=$(echo "$DASHBOARDS_RESPONSE" | grep -o '"uid":"[^"]*"[^}]*"title":"[^"]*[Aa]mbassador[^"]*"' | head -1 | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)

if [[ -z "$AMBASSADOR_DASHBOARD_UID" ]]; then
  echo "[ERROR] Ambassador dashboard not found. Please upload the ambassador dashboard first."
  exit 1
fi

echo "[INFO] Found ambassador dashboard with UID: $AMBASSADOR_DASHBOARD_UID"

# Get all dashboard UIDs
ALL_DASHBOARD_UIDS=$(echo "$DASHBOARDS_RESPONSE" | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)

# Step 3: Set permissions on ALL dashboards
echo "[INFO] Setting dashboard permissions to restrict ambassador access..."

for DASHBOARD_UID in $ALL_DASHBOARD_UIDS; do
  if [[ "$DASHBOARD_UID" == "$AMBASSADOR_DASHBOARD_UID" ]]; then
    # For ambassador dashboard: Allow ONLY ambassador team (View permission)
    echo "[INFO] Setting ambassador dashboard permissions (allowing ambassador team)..."
    PERMISSIONS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID/permissions" \
      -H "Content-Type: application/json" \
      -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" \
      -d "{\"items\": [{\"teamId\": $TEAM_ID, \"permission\": 1}]}")
  else
    # For all other dashboards: Deny ambassador team access (Admin users still have access)
    echo "[INFO] Restricting access to dashboard $DASHBOARD_UID from ambassador team..."
    PERMISSIONS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID/permissions" \
      -H "Content-Type: application/json" \
      -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" \
      -d "{\"items\": [{\"role\": \"Admin\", \"permission\": 4}, {\"role\": \"Editor\", \"permission\": 2}]}")
  fi
  
  PERMISSIONS_HTTP_STATUS=$(echo "$PERMISSIONS_RESPONSE" | tail -n1)
  
  if [[ "$PERMISSIONS_HTTP_STATUS" == "200" || "$PERMISSIONS_HTTP_STATUS" == "201" ]]; then
    echo "[SUCCESS] Permissions set for dashboard $DASHBOARD_UID"
  else
    echo "[WARNING] Failed to set permissions for dashboard $DASHBOARD_UID. HTTP status: $PERMISSIONS_HTTP_STATUS"
  fi
done

echo "[SUCCESS] Ambassador permission restrictions applied!"
echo "[INFO] Ambassador users can now ONLY access the ambassador dashboard."
echo "[INFO] Please ask ambassador users to log out and log back in to see the changes."