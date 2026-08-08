#!/usr/bin/env bash

set -e

echo "==> Checking Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "==> Docker is already installed."
    echo "==> Skipping installation."
    exit 0
fi

echo "==> Docker not found."
echo "==> Installing Docker Rootless..."

curl -fsSL https://get.docker.com/rootless | sh

echo "==> Docker Rootless installation complete."