@echo off
setlocal enabledelayedexpansion

echo 🚀 Self-hosted Supabase Grafana Deployment Helper
echo ==================================================
echo.

echo Please provide your self-hosted Supabase connection details:
echo.

REM Get Supabase connection details
set /p SUPABASE_HOST="Enter your Supabase host (domain/IP): "
set /p SUPABASE_DB="Enter database name [postgres]: "
if "!SUPABASE_DB!"=="" set SUPABASE_DB=postgres
set /p SUPABASE_USER="Enter database user [postgres]: "
if "!SUPABASE_USER!"=="" set SUPABASE_USER=postgres
set /p SUPABASE_PASSWORD="Enter database password: "
set /p SUPABASE_PORT="Enter database port [5432]: "
if "!SUPABASE_PORT!"=="" set SUPABASE_PORT=5432

echo.
echo SSL Configuration:
echo 1. disable - No SSL (development only)
echo 2. require - SSL required (recommended for production)
echo 3. verify-full - SSL with certificate verification (most secure)
set /p SSL_CHOICE="Select SSL mode (1-3) [2]: "
if "!SSL_CHOICE!"=="" set SSL_CHOICE=2

if "!SSL_CHOICE!"=="1" set SUPABASE_SSL_MODE=disable
if "!SSL_CHOICE!"=="2" set SUPABASE_SSL_MODE=require
if "!SSL_CHOICE!"=="3" set SUPABASE_SSL_MODE=verify-full
if not defined SUPABASE_SSL_MODE set SUPABASE_SSL_MODE=require

echo.
echo Grafana Configuration:
set /p GRAFANA_ADMIN_PASSWORD="Enter Grafana admin password: "
set /p GRAFANA_VIEWER_USER="Enter viewer username [viewer]: "
if "!GRAFANA_VIEWER_USER!"=="" set GRAFANA_VIEWER_USER=viewer
set /p GRAFANA_VIEWER_PASSWORD="Enter viewer password: "
set /p GRAFANA_VIEWER_EMAIL="Enter viewer email [viewer@example.com]: "
if "!GRAFANA_VIEWER_EMAIL!"=="" set GRAFANA_VIEWER_EMAIL=viewer@example.com

echo.
echo 📋 Environment Variables for Railway:
echo =====================================
echo.
echo # Supabase Database Configuration
echo SUPABASE_HOST=!SUPABASE_HOST!
echo SUPABASE_DB=!SUPABASE_DB!
echo SUPABASE_USER=!SUPABASE_USER!
echo SUPABASE_PASSWORD=!SUPABASE_PASSWORD!
echo SUPABASE_PORT=!SUPABASE_PORT!
echo SUPABASE_SSL_MODE=!SUPABASE_SSL_MODE!
echo.
echo # Grafana Configuration
echo GRAFANA_ADMIN_PASSWORD=!GRAFANA_ADMIN_PASSWORD!
echo GRAFANA_VIEWER_USER=!GRAFANA_VIEWER_USER!
echo GRAFANA_VIEWER_PASSWORD=!GRAFANA_VIEWER_PASSWORD!
echo GRAFANA_VIEWER_EMAIL=!GRAFANA_VIEWER_EMAIL!
echo.

echo ✅ Setup complete!
echo.
echo Next steps:
echo 1. Copy the environment variables above
echo 2. Go to your Railway project settings
echo 3. Add these as environment variables
echo 4. Deploy your project
echo.
echo For more detailed instructions, see SUPABASE_SETUP.md

pause 