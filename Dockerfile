FROM grafana/grafana:10.4.2

# Switch user to root for installation
USER root

# Install additional tools and plugins (Alpine Linux uses apk)
RUN apk add --no-cache curl wget jq

# Install Grafana plugins at build time for Railway deployment
# Install core plugins that are known to work with Grafana 12.x
RUN set -e; \
    grafana cli plugins install grafana-clock-panel || true; \
    grafana cli plugins install grafana-simple-json-datasource || true; \
    grafana cli plugins install grafana-worldmap-panel || true; \
    grafana cli plugins install grafana-piechart-panel || true; \
    grafana cli plugins install grafana-polystat-panel || true

# Create necessary directories
RUN mkdir -p /var/lib/grafana/dashboards \
    /etc/grafana/provisioning/dashboards \
    /etc/grafana/provisioning/datasources \
    /etc/grafana/provisioning/notifiers \
    /etc/grafana/provisioning/plugins

# Copy custom configuration files
COPY grafana/grafana.ini /etc/grafana/grafana.ini
COPY grafana/provisioning/ /etc/grafana/provisioning/
COPY grafana/dashboards/ /var/lib/grafana/dashboards/
COPY scripts/start.sh /usr/local/bin/start.sh

# Make startup script executable
RUN chmod +x /usr/local/bin/start.sh

# Debug: Ensure grafana user exists before chown
RUN id grafana || (echo 'User grafana does not exist!' && cat /etc/passwd && exit 1)

# Ensure proper ownership
RUN chown -R grafana:root /var/lib/grafana && \
    chown -R grafana:root /etc/grafana

# Switch back to grafana user
USER grafana

# Expose port (Railway will map this automatically)
EXPOSE 3000

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Set working directory
WORKDIR /usr/share/grafana

# Railway-compatible environment variables
ENV GF_SERVER_HTTP_PORT=3000
ENV GF_PATHS_PROVISIONING=/etc/grafana/provisioning
ENV GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin}
ENV GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}
ENV GF_SERVER_ROOT_URL=${RAILWAY_PUBLIC_DOMAIN:-http://localhost:3000}
ENV GF_SERVER_SERVE_FROM_SUB_PATH=false
ENV GF_SECURITY_ALLOW_EMBEDDING=true
ENV GF_AUTH_ANONYMOUS_ENABLED=false
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_LOG_LEVEL=${GRAFANA_LOG_LEVEL:-info}

# Use the startup script as entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"] 