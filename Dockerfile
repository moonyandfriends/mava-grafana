FROM grafana/grafana:10.4.2

# Expose Grafana's default port
EXPOSE 3000

# Ensure Grafana listens on all interfaces (important for Railway)
ENV GF_SERVER_HTTP_ADDR=0.0.0.0

# Start Grafana (default entrypoint)

# Copy provisioning files
COPY grafana/provisioning/datasources/ /etc/grafana/provisioning/datasources/
COPY grafana/provisioning/dashboards/ /etc/grafana/provisioning/dashboards/

# Copy dashboard files
COPY grafana/dashboards/ /var/lib/grafana/dashboards/

# Copy custom scripts
COPY scripts/create_grafana_viewer.sh /scripts/create_grafana_viewer.sh
COPY scripts/deploy_self_hosted.sh /scripts/deploy_self_hosted.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Switch to root to set permissions
USER root
RUN chmod +x /docker-entrypoint.sh /scripts/create_grafana_viewer.sh /scripts/deploy_self_hosted.sh

# Switch back to the default Grafana user
USER 472

# Debug: print SUPABASE_HOST value at build time
RUN echo "SUPABASE_HOST=[$SUPABASE_HOST]"

ENTRYPOINT ["/docker-entrypoint.sh"] 