#!/usr/bin/env bash
set -e

echo "==> Checking local host dependencies..."

if ! command -v vagrant >/dev/null 2>&1; then
  echo "==> Installing Vagrant..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update && sudo apt-get install -y vagrant
else
  echo "==> Vagrant is already installed."
fi

