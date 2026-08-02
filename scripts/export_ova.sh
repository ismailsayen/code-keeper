#!/usr/bin/env bash
set -e

VM_NAME="${1:-Code-Keeper-VM}"
OUTPUT_OVA="${VM_NAME}.ova"

echo "==> Exporting VirtualBox appliance (${VM_NAME}) to ${OUTPUT_OVA}..."
vagrant halt 2>/dev/null || true
VBoxManage export "${VM_NAME}" --output "${OUTPUT_OVA}"
echo "==> OVA export complete: ${OUTPUT_OVA}"