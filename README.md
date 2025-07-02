# Grafana on Railway

This repository contains a minimal setup to run [Grafana](https://grafana.com/) on [Railway](https://railway.app/) using Docker, configured to connect to a Supabase database.

## Deployment

1. Deploy this repo to Railway as a new service.
2. Railway will build the Dockerfile and expose Grafana on port 3000.
3. Access your Grafana instance at the generated Railway URL.

## Supabase Configuration

This Grafana instance is configured to connect to a Supabase database. You can use either:
- **Supabase Cloud** (managed service)
- **Self-hosted Supabase** (your own instance)

> **Quick Setup**: Run `scripts/deploy_self_hosted.sh` (Linux/Mac) or `scripts/deploy_self_hosted.bat` (Windows) to generate your environment variables automatically.

### Required Environment Variables

Set these environment variables in your Railway project settings:

#### For Supabase Cloud:
```bash
SUPABASE_HOST=db.your-project-ref.supabase.co
SUPABASE_DB=postgres
SUPABASE_USER=postgres
SUPABASE_PASSWORD=your-database-password
SUPABASE_PORT=5432
```

#### For Self-hosted Supabase:
```bash
SUPABASE_HOST=your-self-hosted-supabase-domain.com
SUPABASE_DB=postgres
SUPABASE_USER=postgres
SUPABASE_PASSWORD=your-database-password
SUPABASE_PORT=5432
```

### Getting Supabase Connection Details

#### For Supabase Cloud:
1. Go to your Supabase project dashboard
2. Navigate to Settings → Database
3. Copy the connection details from the "Connection string" section

#### For Self-hosted Supabase:
1. Access your self-hosted Supabase instance
2. Navigate to the Database settings or check your deployment configuration
3. Use the connection details from your PostgreSQL database

### SSL Configuration

The current configuration uses `sslmode: disable`. For production environments, you may want to enable SSL:

1. Update `grafana/provisioning/datasources/supabase.yml`
2. Change `sslmode: disable` to `sslmode: require` or `sslmode: verify-full`
3. Add SSL certificate configuration if needed

## Customization
- You can add provisioning files, plugins, or custom configuration by extending the Dockerfile.

## Security
- Set your admin password and other secrets in the Railway environment variables panel.
- Use strong passwords for database connections
- Consider enabling SSL for database connections in production

## Creating a Non-Admin Grafana Viewer User

To automate the creation of a non-admin (Viewer) Grafana user (for Railway or Docker deployments), use the provided script:

```
scripts/create_grafana_viewer.sh
```

### Required Environment Variables
- `GRAFANA_URL` (default: http://localhost:3000)
- `GRAFANA_ADMIN_USER` (default: admin)
- `GRAFANA_ADMIN_PASSWORD` (default: admin)
- `GRAFANA_VIEWER_USER` (required)
- `GRAFANA_VIEWER_PASSWORD` (required)
- `GRAFANA_VIEWER_EMAIL` (required)

### Example Usage

```sh
GRAFANA_VIEWER_USER=viewer \
GRAFANA_VIEWER_PASSWORD=secret \
GRAFANA_VIEWER_EMAIL=viewer@example.com \
./scripts/create_grafana_viewer.sh
```

You can run this script as a Railway post-deploy command or as part of your Docker entrypoint to ensure a viewer user is always available.

## Troubleshooting

### Connection Issues
1. Verify all environment variables are set correctly
2. Check that your Supabase instance is accessible from Railway
3. Ensure the database user has the necessary permissions
4. Verify the port is correct (5432 for standard PostgreSQL)

### SSL Issues
If you encounter SSL-related errors:
1. Check if your self-hosted Supabase uses SSL
2. Update the `sslmode` setting in the datasource configuration
3. Verify SSL certificates are valid

## Additional Resources

- **Detailed Setup Guide**: See [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for comprehensive instructions
- **Troubleshooting**: Check the troubleshooting section in SUPABASE_SETUP.md
- **Security Best Practices**: Review security recommendations in SUPABASE_SETUP.md

---

**Official Grafana Docker image:** https://hub.docker.com/r/grafana/grafana 