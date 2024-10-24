#!/bin/bash

# Check if CPANEL_PASSWORD is set, then change the root password
if [ -n "$CPANEL_PASSWORD" ]; then
  echo "root:${CPANEL_PASSWORD}" | chpasswd
  echo "Root password updated."
else
  echo "No root password provided. Skipping password update."
fi

# Start systemd to ensure all services, including cPanel, are managed correctly
exec /lib/systemd/systemd
