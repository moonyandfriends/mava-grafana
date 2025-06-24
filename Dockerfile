FROM grafana/grafana:10.4.2

# Switch user to root for installation
USER root

# Install additional tools
RUN apk add --no-cache curl wget jq

# Create necessary directories
RUN mkdir -p /var/lib/grafana/dashboards \
    /etc/grafana/provisioning/dashboards \
    /etc/grafana/provisioning/datasources

# Copy custom configuration files
COPY grafana/grafana.ini /etc/grafana/grafana.ini
COPY grafana/provisioning/ /etc/grafana/provisioning/
COPY grafana/dashboards/ /var/lib/grafana/dashboards/
COPY scripts/start.sh /usr/local/bin/start.sh

# Make startup script executable
RUN chmod +x /usr/local/bin/start.sh

# Ensure proper ownership
RUN chown -R grafana:root /var/lib/grafana && \
    chown -R grafana:root /etc/grafana

# Switch back to grafana user
USER grafana

# Set working directory
WORKDIR /usr/share/grafana

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=15s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Railway-compatible environment variables
ENV GF_SERVER_HTTP_PORT=3000
ENV GF_SERVER_DOMAIN=
ENV GF_SERVER_ROOT_URL=
ENV GF_DATABASE_TYPE=sqlite3
ENV GF_DATABASE_PATH=/var/lib/grafana/grafana.db
ENV GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin}
ENV GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin123!@#}
ENV GF_SERVER_SERVE_FROM_SUB_PATH=false
ENV GF_SECURITY_ALLOW_EMBEDDING=true
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_AUTH_ANONYMOUS_ENABLED=false
ENV GF_LOG_LEVEL=${GRAFANA_LOG_LEVEL:-info}

# Use the startup script as the main command
CMD ["/usr/local/bin/start.sh"] 