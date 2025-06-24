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

---

**Official Grafana Docker image:** https://hub.docker.com/r/grafana/grafana 