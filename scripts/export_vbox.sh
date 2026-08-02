#!/usr/bin/env bash
set -e

VM_NAME="${1:-Code-Keeper-VM}"
OUTPUT_BOX="${VM_NAME}.box"

echo "==> Packaging Vagrant VM (${VM_NAME}) to ${OUTPUT_BOX}..."
vagrant halt 2>/dev/null || true
vagrant package --output "${OUTPUT_BOX}"
echo "==> Box export complete: ${OUTPUT_BOX}"