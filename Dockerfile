FROM ayushdabhi31/cpanel-full:latest

# Update the operating system and install necessary packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      # List any additional packages you need here
      && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/cpanel

COPY ./lic .
# Copy the custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the custom entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Ensure systemd runs as the default command
CMD ["/lib/systemd/systemd"]
