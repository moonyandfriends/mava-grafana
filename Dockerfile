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

# Debug: print SUPABASE_HOST value at build time
RUN echo "SUPABASE_HOST=[$SUPABASE_HOST]" 