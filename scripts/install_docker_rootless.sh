#!/usr/bin/env zsh

set -euo pipefail

# ============================================================
# Docker Rootless Installer
# ============================================================
#
# Installs Docker Rootless without sudo.
# Safe to run multiple times.
#
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

info()    { echo -e "${BLUE}ℹ️  $1${RESET}"; }
success() { echo -e "${GREEN}✅ $1${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${RESET}"; }
error()   { echo -e "${RED}❌ $1${RESET}"; }

echo "============================================================"
info "🔍 Checking Docker installation..."
echo "============================================================"

# ------------------------------------------------------------
# Check if Docker already exists
# ------------------------------------------------------------

if command -v docker >/dev/null 2>&1; then

    DOCKER_VERSION=$(docker --version 2>/dev/null)

    if docker info >/dev/null 2>&1; then
        success "Docker is already installed and running."
        echo "$DOCKER_VERSION"
        exit 0
    fi

    if [ -S "${XDG_RUNTIME_DIR:-}/docker.sock" ]; then
        success "Docker Rootless is already configured."
        echo "$DOCKER_VERSION"
        exit 0
    fi

    warn "Docker binary already exists."
    warn "Skipping installation."
    exit 0
fi

# ------------------------------------------------------------
# Install Rootless Docker
# ------------------------------------------------------------

info "Installing Docker Rootless..."

curl -fsSL https://get.docker.com/rootless | sh

success "Docker Rootless installed."

# ------------------------------------------------------------
# Configure environment
# ------------------------------------------------------------

info "Configuring environment..."

grep -qxF 'export PATH=$HOME/bin:$PATH' ~/.zshrc \
    || echo 'export PATH=$HOME/bin:$PATH' >> ~/.zshrc

grep -qxF 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' ~/.zshrc \
    || echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> ~/.zshrc

export PATH="$HOME/bin:$PATH"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

success "Environment configured."

# ------------------------------------------------------------
# Configure Rootless Docker
# ------------------------------------------------------------

if command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then

    info "Running Rootless setup..."

    dockerd-rootless-setuptool.sh install --skip-iptables \
        || warn "Setup completed with warnings."

fi

# ------------------------------------------------------------
# Start daemon
# ------------------------------------------------------------

if pgrep -f dockerd-rootless >/dev/null; then

    success "Docker daemon is already running."

else

    info "Starting Docker daemon..."

    nohup dockerd-rootless.sh \
        > "$HOME/docker-rootless.log" \
        2>&1 &

    sleep 5

fi

# ------------------------------------------------------------
# Install Docker Compose
# ------------------------------------------------------------

if docker compose version >/dev/null 2>&1; then

    success "Docker Compose already installed."

else

    info "Installing Docker Compose..."

    mkdir -p ~/.docker/cli-plugins

    curl -SL \
        https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
        -o ~/.docker/cli-plugins/docker-compose

    chmod +x ~/.docker/cli-plugins/docker-compose

    success "Docker Compose installed."

fi

# ------------------------------------------------------------
# Verify installation
# ------------------------------------------------------------

echo
info "Verifying installation..."
echo

docker --version
docker compose version

echo

if docker info >/dev/null 2>&1; then
    success "Docker Rootless is ready."
else
    warn "Docker installed but daemon is not responding."
    warn "Restart your terminal and run:"
    echo
    echo "    source ~/.zshrc"
    echo "    dockerd-rootless.sh"
fi

echo
success "Installation completed."