#!/usr/bin/env bash

set -e

echo "==> Starting Tailscale..."

mkdir -p /var/lib/tailscale

tailscaled \
    --tun=userspace-networking \
    --socks5-server=127.0.0.1:1055 \
    --state=/var/lib/tailscale/tailscaled.state \
    >/tmp/tailscaled.log 2>&1 &

TAILSCALED_PID=$!

echo "==> Waiting for Tailscale daemon..."

for i in $(seq 1 30); do
    if tailscale status >/dev/null 2>&1; then
        break
    fi

    sleep 1
done

if [ -z "$TS_AUTHKEY" ]; then
    echo "ERROR: TS_AUTHKEY is not set."
    exit 1
fi

echo "==> Connecting to Tailscale..."

tailscale up \
    --auth-key="$TS_AUTHKEY" \
    --hostname="code-keeper-toolbox"

echo "==> Tailscale connected."

echo "==> Tailscale status:"
tailscale status

echo "==> SOCKS5 proxy available on 127.0.0.1:1055"

exec "$@"