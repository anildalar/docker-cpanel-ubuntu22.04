FROM ayushdabhi31/cpanel-full

# Copy the custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the custom entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Ensure systemd runs as the default command
CMD ["/lib/systemd/systemd"]
