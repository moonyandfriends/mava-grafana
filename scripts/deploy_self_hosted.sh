#!/bin/bash

# Self-hosted Supabase Deployment Helper Script
# This script helps you set up environment variables for connecting to your self-hosted Supabase instance

set -e

echo "🚀 Self-hosted Supabase Grafana Deployment Helper"
echo "=================================================="
echo ""

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        input=${input:-$default}
    else
        read -p "$prompt: " input
    fi
    
    eval "$var_name='$input'"
}

echo "Please provide your self-hosted Supabase connection details:"
echo ""

# Get Supabase connection details
prompt_with_default "Enter your Supabase host (domain/IP)" "" SUPABASE_HOST
prompt_with_default "Enter database name" "postgres" SUPABASE_DB
prompt_with_default "Enter database user" "postgres" SUPABASE_USER
prompt_with_default "Enter database password" "" SUPABASE_PASSWORD
prompt_with_default "Enter database port" "5432" SUPABASE_PORT

echo ""
echo "SSL Configuration:"
echo "1. disable - No SSL (development only)"
echo "2. require - SSL required (recommended for production)"
echo "3. verify-full - SSL with certificate verification (most secure)"
prompt_with_default "Select SSL mode (1-3)" "2" SSL_CHOICE

case $SSL_CHOICE in
    1) SUPABASE_SSL_MODE="disable" ;;
    2) SUPABASE_SSL_MODE="require" ;;
    3) SUPABASE_SSL_MODE="verify-full" ;;
    *) SUPABASE_SSL_MODE="require" ;;
esac

echo ""
echo "Grafana Configuration:"
prompt_with_default "Enter Grafana admin password" "" GRAFANA_ADMIN_PASSWORD
prompt_with_default "Enter viewer username" "viewer" GRAFANA_VIEWER_USER
prompt_with_default "Enter viewer password" "" GRAFANA_VIEWER_PASSWORD
prompt_with_default "Enter viewer email" "viewer@example.com" GRAFANA_VIEWER_EMAIL

echo ""
echo "📋 Environment Variables for Railway:"
echo "====================================="
echo ""
echo "# Supabase Database Configuration"
echo "SUPABASE_HOST=$SUPABASE_HOST"
echo "SUPABASE_DB=$SUPABASE_DB"
echo "SUPABASE_USER=$SUPABASE_USER"
echo "SUPABASE_PASSWORD=$SUPABASE_PASSWORD"
echo "SUPABASE_PORT=$SUPABASE_PORT"
echo "SUPABASE_SSL_MODE=$SUPABASE_SSL_MODE"
echo ""
echo "# Grafana Configuration"
echo "GRAFANA_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASSWORD"
echo "GRAFANA_VIEWER_USER=$GRAFANA_VIEWER_USER"
echo "GRAFANA_VIEWER_PASSWORD=$GRAFANA_VIEWER_PASSWORD"
echo "GRAFANA_VIEWER_EMAIL=$GRAFANA_VIEWER_EMAIL"
echo ""

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy the environment variables above"
echo "2. Go to your Railway project settings"
echo "3. Add these as environment variables"
echo "4. Deploy your project"
echo ""
echo "For more detailed instructions, see SUPABASE_SETUP.md" 