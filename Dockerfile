FROM ubuntu:22.04

# Install curl and wget
# Update the package list and install required packages
RUN apt-get update && \
apt-get install -y curl wget iproute2 perl && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

WORKDIR /root
COPY entrypoint.sh .


# Set the entrypoint script to be executable
RUN chmod +x entrypoint.sh

# Specify the entrypoint
ENTRYPOINT ["/root/entrypoint.sh"]

