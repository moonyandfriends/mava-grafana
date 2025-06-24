#!/bin/sh

# If Railway injected $PORT, use it
[ -n "$PORT" ] && export GF_SERVER_HTTP_PORT="$PORT"

exec grafana-server \
     --homepath=/usr/share/grafana \
     --config=/etc/grafana/grafana.ini 