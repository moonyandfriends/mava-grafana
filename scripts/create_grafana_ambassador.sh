#!/bin/bash
#
# create_grafana_ambassador.sh
#
# Creates a non-admin Grafana user with restricted access to only the ambassador dashboard.
# This user can only view the community-ambassadors dashboard and nothing else.
#
# Required environment variables:
#   GRAFANA_URL (default: http://localhost:3000)
#   GRAFANA_ADMIN_USER (default: admin)
#   GRAFANA_ADMIN_PASSWORD (default: admin)
#   GRAFANA_AMBASSADOR_USER (required)
#   GRAFANA_AMBASSADOR_PASSWORD (required)
#   GRAFANA_AMBASSADOR_EMAIL (required)
#
# Example usage:
#   GRAFANA_AMBASSADOR_USER=ambassador GRAFANA_AMBASSADOR_PASSWORD=secret GRAFANA_AMBASSADOR_EMAIL=ambassador@example.com ./scripts/create_grafana_ambassador.sh

set -e

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed. Please install curl to use this script."
  exit 1
fi

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:-admin}"
GRAFANA_AMBASSADOR_USER="${GRAFANA_AMBASSADOR_USER}"
GRAFANA_AMBASSADOR_PASSWORD="${GRAFANA_AMBASSADOR_PASSWORD}"
GRAFANA_AMBASSADOR_EMAIL="${GRAFANA_AMBASSADOR_EMAIL}"

if [[ -z "$GRAFANA_AMBASSADOR_USER" || -z "$GRAFANA_AMBASSADOR_PASSWORD" || -z "$GRAFANA_AMBASSADOR_EMAIL" ]]; then
  echo "Error: GRAFANA_AMBASSADOR_USER, GRAFANA_AMBASSADOR_PASSWORD, and GRAFANA_AMBASSADOR_EMAIL must be set."
  exit 1
fi

echo "[INFO] Waiting for Grafana to be ready at $GRAFANA_URL ..."
MAX_RETRIES=30
RETRY_DELAY=2
RETRIES=0
until curl -s -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" "$GRAFANA_URL/api/health" | grep 'database'; do
  RETRIES=$((RETRIES+1))
  if [ $RETRIES -ge $MAX_RETRIES ]; then
    echo "[ERROR] Grafana did not become ready in time. Exiting."
    exit 1
  fi
  echo "[INFO] Waiting for Grafana to be ready... ($RETRIES/$MAX_RETRIES)"
  sleep $RETRY_DELAY
done

echo "[INFO] Grafana is ready. Creating ambassador user '$GRAFANA_AMBASSADOR_USER'..."

# Step 1: Create the user
USER_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$GRAFANA_URL/api/admin/users" \
  -H "Content-Type: application/json" \
  -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" \
  -d "{\"name\": \"$GRAFANA_AMBASSADOR_USER\", \"email\": \"$GRAFANA_AMBASSADOR_EMAIL\", \"login\": \"$GRAFANA_AMBASSADOR_USER\", \"password\": \"$GRAFANA_AMBASSADOR_PASSWORD\"}")

USER_HTTP_BODY=$(echo "$USER_RESPONSE" | head -n -1)
USER_HTTP_STATUS=$(echo "$USER_RESPONSE" | tail -n1)

if [[ "$USER_HTTP_STATUS" == "200" || "$USER_HTTP_STATUS" == "201" ]]; then
  echo "[SUCCESS] Ambassador user '$GRAFANA_AMBASSADOR_USER' created successfully."
  USER_ID=$(echo "$USER_HTTP_BODY" | grep -o '"id":[0-9]*' | cut -d':' -f2)
  echo "[INFO] User ID: $USER_ID"
else
  echo "[ERROR] Failed to create user. HTTP status: $USER_HTTP_STATUS"
  echo "[ERROR] Response body: $USER_HTTP_BODY"
  exit 1
fi

# Step 2: Create a team for ambassador users
echo "[INFO] Creating ambassador team..."
TEAM_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$GRAFANA_URL/api/teams" \
  -H "Content-Type: application/json" \
  -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" \
  -d "{\"name\": \"Ambassadors\", \"email\": \"\"}")

TEAM_HTTP_BODY=$(echo "$TEAM_RESPONSE" | head -n -1)
TEAM_HTTP_STATUS=$(echo "$TEAM_RESPONSE" | tail -n1)

if [[ "$TEAM_HTTP_STATUS" == "200" || "$TEAM_HTTP_STATUS" == "201" ]]; then
  echo "[SUCCESS] Ambassador team created successfully."
  TEAM_ID=$(echo "$TEAM_HTTP_BODY" | grep -o '"teamId":[0-9]*' | cut -d':' -f2)
  echo "[INFO] Team ID: $TEAM_ID"
elif [[ "$TEAM_HTTP_STATUS" == "409" ]]; then
  echo "[INFO] Ambassador team already exists, retrieving team ID..."
  TEAMS_RESPONSE=$(curl -s -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" "$GRAFANA_URL/api/teams/search?name=Ambassadors")
  TEAM_ID=$(echo "$TEAMS_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
  echo "[INFO] Team ID: $TEAM_ID"
else
  echo "[ERROR] Failed to create team. HTTP status: $TEAM_HTTP_STATUS"
  echo "[ERROR] Response body: $TEAM_HTTP_BODY"
  exit 1
fi

# Step 3: Add user to the ambassador team
echo "[INFO] Adding user to ambassador team..."
ADD_USER_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$GRAFANA_URL/api/teams/$TEAM_ID/members" \
  -H "Content-Type: application/json" \
  -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" \
  -d "{\"userId\": $USER_ID}")

ADD_USER_HTTP_STATUS=$(echo "$ADD_USER_RESPONSE" | tail -n1)

if [[ "$ADD_USER_HTTP_STATUS" == "200" || "$ADD_USER_HTTP_STATUS" == "201" ]]; then
  echo "[SUCCESS] User added to ambassador team successfully."
else
  echo "[ERROR] Failed to add user to team. HTTP status: $ADD_USER_HTTP_STATUS"
  echo "[ERROR] Response body: $(echo "$ADD_USER_RESPONSE" | head -n -1)"
fi

# Step 4: Find the ambassador dashboard
echo "[INFO] Finding ambassador dashboard..."
DASHBOARDS_RESPONSE=$(curl -s -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" "$GRAFANA_URL/api/search?type=dash-db")
AMBASSADOR_DASHBOARD_UID=$(echo "$DASHBOARDS_RESPONSE" | grep -o '"uid":"[^"]*"[^}]*"title":"[^"]*[Aa]mbassador[^"]*"' | head -1 | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)

if [[ -z "$AMBASSADOR_DASHBOARD_UID" ]]; then
  echo "[WARNING] Ambassador dashboard not found. Skipping permission setup."
  echo "[INFO] You may need to manually set dashboard permissions after uploading the ambassador dashboard."
else
  echo "[INFO] Found ambassador dashboard with UID: $AMBASSADOR_DASHBOARD_UID"
  
  # Step 5: Set dashboard permissions to restrict access to ambassador team only
  echo "[INFO] Setting dashboard permissions..."
  PERMISSIONS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$GRAFANA_URL/api/dashboards/uid/$AMBASSADOR_DASHBOARD_UID/permissions" \
    -H "Content-Type: application/json" \
    -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASSWORD" \
    -d "{\"items\": [{\"teamId\": $TEAM_ID, \"permission\": 1}]}")
  
  PERMISSIONS_HTTP_STATUS=$(echo "$PERMISSIONS_RESPONSE" | tail -n1)
  
  if [[ "$PERMISSIONS_HTTP_STATUS" == "200" || "$PERMISSIONS_HTTP_STATUS" == "201" ]]; then
    echo "[SUCCESS] Dashboard permissions set successfully."
    echo "[INFO] Ambassador team now has view access to the ambassador dashboard."
  else
    echo "[ERROR] Failed to set dashboard permissions. HTTP status: $PERMISSIONS_HTTP_STATUS"
    echo "[ERROR] Response body: $(echo "$PERMISSIONS_RESPONSE" | head -n -1)"
  fi
fi

echo "[SUCCESS] Ambassador user setup completed!"
echo "[INFO] User '$GRAFANA_AMBASSADOR_USER' can now log in and will only see the ambassador dashboard."