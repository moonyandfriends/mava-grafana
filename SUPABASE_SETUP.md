# Supabase Connection Setup Guide

This guide will help you configure your Grafana instance to connect to your self-hosted Supabase database.

## Environment Variables Required

Set these environment variables in your Railway project settings:

```bash
# Supabase Database Configuration
SUPABASE_HOST=your-self-hosted-supabase-domain.com
SUPABASE_DB=postgres
SUPABASE_USER=postgres
SUPABASE_PASSWORD=your-database-password
SUPABASE_PORT=5432
```

## Getting Your Self-hosted Supabase Connection Details

### Method 1: From Supabase Dashboard
1. Access your self-hosted Supabase dashboard
2. Navigate to Settings → Database
3. Look for the connection string or connection details
4. Extract the host, database name, user, and password

### Method 2: From Docker Compose (if using Docker)
If you deployed Supabase using Docker Compose, check your `docker-compose.yml` file:
```yaml
services:
  db:
    image: supabase/postgres
    environment:
      POSTGRES_PASSWORD: your-password
      POSTGRES_USER: postgres
      POSTGRES_DB: postgres
    ports:
      - "5432:5432"
```

### Method 3: From Direct PostgreSQL Connection
If you have direct access to your PostgreSQL database:
```bash
# Connect to your database
psql -h your-host -U postgres -d postgres

# Check connection info
\conninfo
```

## SSL Configuration

The current configuration uses `sslmode: disable`. For production environments, you should enable SSL:

### Option 1: Update the datasource configuration
Edit `grafana/provisioning/datasources/supabase.yml`:
```yaml
jsonData:
  sslmode: require  # or verify-full for stricter SSL
  postgresVersion: 1300
  port: ${SUPABASE_PORT}
```

### Option 2: Use environment variable (recommended)
Add this environment variable:
```bash
SUPABASE_SSL_MODE=require
```

And update the datasource configuration to use it:
```yaml
jsonData:
  sslmode: ${SUPABASE_SSL_MODE}
  postgresVersion: 1300
  port: ${SUPABASE_PORT}
```

## Testing the Connection

1. Deploy your Grafana instance with the updated environment variables
2. Access your Grafana dashboard
3. Go to Configuration → Data Sources
4. Check if the Supabase datasource shows as "OK"
5. If there are errors, check the logs for connection details

## Common Issues and Solutions

### Connection Refused
- Verify the host and port are correct
- Ensure your Supabase instance is accessible from Railway
- Check if any firewall rules are blocking the connection

### Authentication Failed
- Verify the username and password are correct
- Ensure the database user has the necessary permissions
- Check if the user exists in your self-hosted Supabase

### SSL Issues
- If using SSL, ensure your self-hosted Supabase has SSL configured
- Try different SSL modes: `disable`, `require`, `verify-full`
- Check if SSL certificates are valid and trusted

### Database Not Found
- Verify the database name is correct (usually `postgres`)
- Ensure the database exists in your self-hosted Supabase instance

## Security Best Practices

1. **Use strong passwords** for database connections
2. **Enable SSL** for production environments
3. **Use environment variables** instead of hardcoding credentials
4. **Limit database user permissions** to only what's necessary
5. **Regularly rotate passwords** and update environment variables
6. **Monitor connection logs** for any suspicious activity

## Example Railway Environment Variables

Here's a complete example of what your Railway environment variables should look like:

```bash
# Grafana Configuration
GRAFANA_ADMIN_PASSWORD=your-secure-admin-password
GRAFANA_VIEWER_USER=viewer
GRAFANA_VIEWER_PASSWORD=your-secure-viewer-password
GRAFANA_VIEWER_EMAIL=viewer@yourdomain.com

# Supabase Database Configuration
SUPABASE_HOST=your-supabase.yourdomain.com
SUPABASE_DB=postgres
SUPABASE_USER=postgres
SUPABASE_PASSWORD=your-secure-database-password
SUPABASE_PORT=5432
SUPABASE_SSL_MODE=require
``` 