#!/usr/bin/env bash

set -e

: "${CODE_KEEPER_HOST:?CODE_KEEPER_HOST is not set}"
: "${TAILSCALE_PROXY:?TAILSCALE_PROXY is not set}"

GITLAB_URL="http://${CODE_KEEPER_HOST}"
CHROME_PROFILE="/tmp/code-keeper-gitlab"

echo "==> Opening GitLab..."
echo "==> URL: ${GITLAB_URL}"
echo "==> Proxy: ${TAILSCALE_PROXY}"

if command -v google-chrome >/dev/null 2>&1; then
    google-chrome \
        --user-data-dir="$CHROME_PROFILE" \
        --proxy-server="socks5://${TAILSCALE_PROXY}" \
        "$GITLAB_URL" &

elif command -v chrome.exe >/dev/null 2>&1; then
    chrome.exe \
        --user-data-dir="$CHROME_PROFILE" \
        --proxy-server="socks5://${TAILSCALE_PROXY}" \
        "$GITLAB_URL" &

else
    echo "ERROR: Google Chrome was not found."
    exit 1
fi