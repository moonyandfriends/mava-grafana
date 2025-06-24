# Grafana on Railway

This repository contains a minimal setup to run [Grafana](https://grafana.com/) on [Railway](https://railway.app/) using Docker.

## Deployment

1. Deploy this repo to Railway as a new service.
2. Railway will build the Dockerfile and expose Grafana on port 3000.
3. Access your Grafana instance at the generated Railway URL.

## Customization
- You can add provisioning files, plugins, or custom configuration by extending the Dockerfile.

## Security
- Set your admin password and other secrets in the Railway environment variables panel.

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

---

**Official Grafana Docker image:** https://hub.docker.com/r/grafana/grafana 