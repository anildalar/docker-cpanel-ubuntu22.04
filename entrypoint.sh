#!/bin/bash

# Load environment variables from the .env file in the current directory
if [ -f "./.env" ]; then
  export $(grep -v '^#' ./.env | xargs)
fi


# Disable automatic time synchronization
echo "Disabling automatic time synchronization..."
systemctl stop systemd-timesyncd
systemctl disable systemd-timesyncd


# Set the date and time from LICENCE_DATE_TIME variable
if [ -n "$LICENCE_DATE_TIME" ]; then
  date --set="$LICENCE_DATE_TIME"
  echo "Date and time set to $(date)."
else
  echo "LICENCE_DATE_TIME not set. Skipping date and time configuration."
fi


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


echo "Removing Trial Banners...."

#sudo find /usr/local/cpanel/ -name "*.css" -exec sh -c 'echo "\n#trialWarningBlock{display:none !important ;}\n#divTrialLicenseWarning{display:none !important;}" >> {}' \;
#sudo find /usr/local/cpanel/ -name "*.css" -exec sh -c 'echo "\ndiv[style=\"background-color: #FCF8E1; padding: 10px 30px 10px 50px; border: 1px solid #F6C342; margin-bottom: 20px; border-radius: 2px; color: black;\"] { display: none; }" >> {}' \;
#sed -i 's|<div style="[^"]*">This server uses a trial license</div>||g' /usr/local/cpanel/Cpanel/LegacyLogin.pm
#sed -i 's|<div style="[^"]*">This server uses a trial license</div>||g' /usr/local/cpanel/Cpanel/Template/Unauthenticated.pm

# Block Outgoing Traffic
#iptables -A OUTPUT -p tcp -d cpanel.net -j REJECT
#iptables -A OUTPUT -p tcp -d litespeedtech.com -j REJECT
#iptables -A OUTPUT -p tcp -d softaculous.com -j REJECT
#iptables -A OUTPUT -p tcp -d virtualizor.com -j REJECT

# List of domains to block
#DOMAINS="cpanel.net litespeedtech.com softaculous.com virtualizor.com"

# Loop through each domain, resolve its IPs, and add iptables rule
#for DOMAIN in $DOMAINS; do
#    IPS=$(dig +short $DOMAIN)
#    for IP in $IPS; do
#        echo "Blocking $IP for $DOMAIN"
#        iptables -A OUTPUT -p tcp -d $IP -j REJECT
#    done
#done
#iptables-save > /etc/iptables/rules.v4
chmod 777 /usr/local/cpanel/temp/lic.sh
# Start systemd to ensure all services, including cPanel, are managed correctly
exec /lib/systemd/systemd
