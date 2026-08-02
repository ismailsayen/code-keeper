#!/usr/bin/env bash
# Description: Safely extract GitLab initial root password and write to a secure local file.

set -e

OUTPUT_FILE="gitlab_root_password"

echo "==> Fetching initial root password..."

# Check if the VM is running
if vagrant status | grep -q "running"; then
  # Fetch password string and isolate second column
  vagrant ssh -c "sudo cat /etc/gitlab/initial_root_password | grep 'Password:'" 2>/dev/null | awk '{print $2}' > "${OUTPUT_FILE}"

  # Verify file is not empty
  if [ -s "${OUTPUT_FILE}" ]; then
    chmod 600 "${OUTPUT_FILE}"
    echo "==> Password saved successfully to '${OUTPUT_FILE}'"
  else
    rm -f "${OUTPUT_FILE}"
    echo "==> Password file does not exist on VM (it may have been deleted after 24 hours)."
  fi
else
  echo "==> VM is not running. Run 'make up' first."
  exit 1
fi