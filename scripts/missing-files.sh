#!/usr/bin/env bash

# ============================================================
# Missing Files Bootstrap Script
# ============================================================
#
# This script creates required local files that are ignored
# by Git because they contain sensitive information.
#
# It also checks for Vagrant environment requirements.
#
# Run after cloning:
#
#     ./scripts/missing-files.sh
#
# ============================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ============================================================
# Colors
# ============================================================

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
RESET="\033[0m"


echo -e "${BLUE}"
echo "============================================================"
echo "🔍 Checking required local project files..."
echo "============================================================"
echo -e "${RESET}"

echo "Project root: $PROJECT_ROOT"
echo


# ============================================================
# Create missing files
# ============================================================

create_file() {
    local file=$1
    local content=$2

    if [ -f "$PROJECT_ROOT/$file" ]; then
        echo -e "${GREEN}✅ $file already exists${RESET}"
    else
        echo -e "${YELLOW}⚠️  Creating missing file: $file${RESET}"

        cat > "$PROJECT_ROOT/$file" <<EOF
$content
EOF

        chmod 600 "$PROJECT_ROOT/$file"

        echo -e "${GREEN}✅ Created $file${RESET}"
    fi

    echo
}


# ============================================================
# Secret files
# ============================================================

create_file ".vault_pass" \
"# ============================================================
# Ansible Vault Password File
# ============================================================
#
# This file is used by Ansible Vault.
#
# WARNING:
# Replace this content with the real vault password.
#
# DO NOT COMMIT THIS FILE.
#
# Example:
#
# my-secret-password
#
# ============================================================
"


create_file ".tailscale_key" \
"# ============================================================
# Tailscale Authentication Key
# ============================================================
#
# This file contains the Tailscale auth key used for joining
# machines/nodes to the private network.
#
# WARNING:
# Replace this content with your real Tailscale key.
#
# DO NOT COMMIT THIS FILE.
#
# Example:
#
# tskey-auth-xxxxxxxxxxxxxxxx
#
# ============================================================
"


# ============================================================
# Vagrant environment check
# ============================================================

echo -e "${BLUE}"
echo "============================================================"
echo "📦 Checking Vagrant environment..."
echo "============================================================"
echo -e "${RESET}"


if [ -d "$PROJECT_ROOT/.vagrant" ]; then

    echo -e "${GREEN}✅ .vagrant directory exists${RESET}"
    echo
    echo "Checking VM metadata..."

    if [ -f "$PROJECT_ROOT/.vagrant/machines/default/virtualbox/id" ]; then

        VM_ID=$(cat "$PROJECT_ROOT/.vagrant/machines/default/virtualbox/id")

        echo -e "${GREEN}Current VM ID:${RESET}"
        echo "$VM_ID"

    else

        echo -e "${YELLOW}⚠️  VM ID file is missing${RESET}"
        echo
        echo "Expected:"
        echo ".vagrant/machines/default/virtualbox/id"

    fi


else

    echo -e "${YELLOW}"
    echo "⚠️  .vagrant directory is missing"
    echo -e "${RESET}"

    echo "
The .vagrant directory is required for the existing VM environment.

It contains:
  - Virtual machine ID
  - SSH private keys
  - Vagrant machine metadata
  - Provider information

IMPORTANT:
The .vagrant directory is NOT stored in Git.

If this repository was cloned on a new machine:

1. Import the provided OVA virtual machine.

2. Restore the .vagrant directory manually.

3. Update the VM ID:

   File:
   .vagrant/machines/default/virtualbox/id

4. Get the new VirtualBox UUID:

   VBoxManage list vms

5. Replace the old ID with the new VM UUID.

Example:

Old:
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

New:
$(VBoxManage list vms 2>/dev/null | head -1 || echo "NEW-VM-UUID")

Without updating this ID, Vagrant will not be able to communicate
with the imported virtual machine.
"

fi


# ============================================================
# Summary
# ============================================================

echo
echo -e "${BLUE}"
echo "============================================================"
echo "🎉 Missing files check completed"
echo "============================================================"
echo -e "${RESET}"

echo
echo "Created / checked:"
echo "  ✔ .vault_pass"
echo "  ✔ .tailscale_key"
echo "  ✔ .vagrant"
echo

echo -e "${RED}Security reminders:${RESET}"
echo "  - Never commit secrets"
echo "  - Never commit .vagrant/"
echo "  - Keep sensitive files in secure storage"
echo

echo -e "${GREEN}Your local environment is ready to configure 🚀${RESET}"