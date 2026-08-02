#!/usr/bin/env bash

set -e
export DEBIAN_FRONTEND=noninteractive



echo "==> Updating system packages..."
apt-get update -y
apt-get upgrade -y

DETECTED_IP=$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

# Fallback to hostname if no valid IP detected
VM_IP="${DETECTED_IP:-$(hostname -I | awk '{print $1}')}"

if [ -z "${VM_IP}" ]; then
  VM_IP="localhost"
fi

echo "==> Auto-detected VM IP: http://${VM_IP}"


echo "==> Installing basic dependencies..."
apt-get install -y curl openssh-server ca-certificates tzdata perl postfix ufw

# -----------------------------------------------------------------
# 1. Setup 4GB Swap Space (Prevents OOM errors during compilation/runs)
# -----------------------------------------------------------------
if [ ! -f /swapfile ]; then
  echo "==> Configuring 4GB Swap Space..."
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
  sysctl vm.swappiness=10
  echo 'vm.swappiness=10' >> /etc/sysctl.conf
fi

# -----------------------------------------------------------------
# 2. Add Repository & Install GitLab CE
# -----------------------------------------------------------------
if ! command -v gitlab-ctl >/dev/null 2>&1; then
  echo "==> Adding GitLab Package Repository..."
  curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

  echo "==> Installing GitLab Community Edition..."
  EXTERNAL_URL="http://${VM_IP}" apt-get install -y gitlab-ce
else
  echo "==> GitLab is already installed. Updating external_url..."
  
  # Update external_url in gitlab.rb to match current IP and reconfigure
  sudo sed -i "s|^external_url .*|external_url 'http://${VM_IP}'|" /etc/gitlab/gitlab.rb
  sudo gitlab-ctl reconfigure
fi

# -----------------------------------------------------------------
# 3. Configure Firewall Rules
# -----------------------------------------------------------------
echo "==> Setting up firewall rules..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "============================================================"
echo " GitLab Installation Complete!"
echo " URL: http://${VM_IP} (or http://localhost:8080)"
echo " Initial Root Password File: /etc/gitlab/initial_root_password"
echo "============================================================"