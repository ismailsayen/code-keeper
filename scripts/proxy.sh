#!/usr/bin/env bash
set -e

CONTAINER_NAME="tailscale-proxy"
KEY_FILE=".tailscale_key"
GITLAB_IP="100.110.28.100"

case "$1" in
  up)
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
      echo "==> Proxy is already running."
      exit 0
    fi

    KEY="${TS_AUTHKEY:-$(cat "$KEY_FILE" 2>/dev/null || true)}"
    if [ -z "$KEY" ]; then
      echo "==> Error: Missing $KEY_FILE file or TS_AUTHKEY env variable!"
      exit 1
    fi

    echo "==> Starting Tailscale Proxy container..."
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker run -d \
      --name "$CONTAINER_NAME" \
      -e TS_AUTHKEY="$KEY" \
      -e TS_USERSPACE=true \
      -e TS_SOCKS5_SERVER=":1055" \
      -p 127.0.0.1:1055:1055 \
      --restart unless-stopped \
      tailscale/tailscale:latest >/dev/null

    echo "==> Proxy running on 127.0.0.1:1055"
    ;;

  down)
    echo "==> Stopping Tailscale Proxy..."
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    ;;

  open)
      "$0" up
      echo "==> Opening GitLab in Chrome from WSL..."

      # 1. Try Windows Chrome executable via cmd.exe (Standard WSL approach)
      if command -v cmd.exe >/dev/null 2>&1; then
        cmd.exe /c start chrome \
          --user-data-dir="C:\Windows\Temp\chrome_tailscale_proxy" \
          --proxy-server="socks5://127.0.0.1:1055" \
          "http://${GITLAB_IP}" >/dev/null 2>&1 &

      # 2. Fallback for native Linux Chrome desktop
      elif command -v google-chrome >/dev/null 2>&1; then
        google-chrome \
          --user-data-dir="/tmp/chrome_tailscale_proxy" \
          --proxy-server="socks5://127.0.0.1:1055" \
          "http://${GITLAB_IP}" >/dev/null 2>&1 &
      else
        echo "==> Error: Could not launch Chrome!"
        exit 1
      fi
      ;;

    *)
      echo "Usage: $0 {up|down|open}"
      exit 1
      ;;

esac