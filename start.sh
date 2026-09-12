#!/usr/bin/env bash

set -e

# Railway provides the PORT environment variable.
PORT="${PORT:-7681}"

# Basic authentication credentials.
WEB_USER="${WEB_USER:-admin}"
WEB_PASS="${WEB_PASS:-changeme}"

if [ -z "$WEB_USER" ] || [ -z "$WEB_PASS" ]; then
    echo "ERROR: WEB_USER and WEB_PASS must be set."
    exit 1
fi

echo "=========================================="
echo " Railway Web Terminal"
echo "=========================================="
echo "Port: $PORT"
echo "User: $WEB_USER"
echo "Starting ttyd..."
echo "=========================================="

exec ttyd \
    --port "$PORT" \
    --interface 0.0.0.0 \
    --credential "$WEB_USER:$WEB_PASS" \
    --writable \
    bash
