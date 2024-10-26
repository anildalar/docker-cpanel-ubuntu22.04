FROM oklabs/cpanel-whm-full-nulled:latest

# OS Update & Upgrade
# RUN apt-get update && apt-get upgrade -y && apt-get install -y fake-hwclock vim && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/cpanel

COPY ./lic .
# Copy the custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY ./temp/lic.sh /usr/local/cpanel/temp/lic.sh
RUN chmod +x /usr/local/cpanel/temp/lic.sh

# Use the custom entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


