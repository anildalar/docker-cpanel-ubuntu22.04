#!/bin/bash

# Check if CPANEL_PASSWORD is set, then change the root password
if [ -n "$CPANEL_PASSWORD" ]; then
  echo "root:${CPANEL_PASSWORD}" | chpasswd
  echo "Root password updated."
else
  echo "No root password provided. Skipping password update."
fi

# Check if UPDATE_CPANEL_TO_LATEST is set to true
if [ "$UPDATE_CPANEL_TO_LATEST" == "true" ]; then
  echo "Updating cPanel to the latest version..."
  /scripts/upcp --force
  if [ $? -eq 0 ]; then
    echo "cPanel updated successfully."
  else
    echo "cPanel update failed."
    exit 1
  fi
else
  echo "Skipping cPanel update."
fi

# Start systemd to ensure all services, including cPanel, are managed correctly
exec /lib/systemd/systemd
