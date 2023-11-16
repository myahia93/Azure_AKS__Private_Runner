FROM ubuntu:20.04

# Update the package repository and upgrade existing packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install essential packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Set the target architecture (Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64')
ENV TARGETARCH=linux-x64

# Set the working directory
WORKDIR /azp

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends nodejs

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the start script
COPY ./start.sh .
RUN chmod +x start.sh

# Set the entrypoint
ENTRYPOINT [ "./start.sh" ]