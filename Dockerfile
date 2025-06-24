FROM grafana/grafana:10.4.2

# Expose Grafana's default port
EXPOSE 3000

# Ensure Grafana listens on all interfaces (important for Railway)
ENV GF_SERVER_HTTP_ADDR=0.0.0.0

# Start Grafana (default entrypoint) 