#!/usr/bin/env bash

set -e

PORT="${PORT:-7681}"
WEB_USER="${WEB_USER:-admin}"
WEB_PASS="${WEB_PASS:-changeme}"

echo "=========================================="
echo " Railway VPS-style Environment"
echo "=========================================="

# Start containerd
if command -v containerd >/dev/null 2>&1; then
    containerd > /tmp/containerd.log 2>&1 &
fi

sleep 2

# Start Docker daemon
if command -v dockerd >/dev/null 2>&1; then
    echo "Starting Docker daemon..."

    dockerd \
        --host=unix:///var/run/docker.sock \
        --iptables=false \
        --bridge=none \
        > /tmp/dockerd.log 2>&1 &

    DOCKER_PID=$!

    echo "Docker PID: $DOCKER_PID"

    for i in $(seq 1 30); do
        if docker info >/dev/null 2>&1; then
            echo "Docker daemon is RUNNING."
            break
        fi

        if ! kill -0 "$DOCKER_PID" 2>/dev/null; then
            echo "Docker daemon exited."
            cat /tmp/dockerd.log
            break
        fi

        sleep 1
    done
fi

echo "=========================================="
echo "Docker version:"
docker --version || true

echo "Docker status:"
docker info || true

echo "=========================================="
echo "Starting Web Terminal..."
echo "=========================================="

exec ttyd \
    --port "$PORT" \
    --interface 0.0.0.0 \
    --credential "$WEB_USER:$WEB_PASS" \
    --writable \
    bash
