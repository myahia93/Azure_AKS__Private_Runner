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

# Install Terraform & prerequisite packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends unzip
# Terraform 1.2.0
RUN curl -LO https://releases.hashicorp.com/terraform/1.2.0/terraform_1.2.0_linux_amd64.zip && \
    unzip terraform_1.2.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform_1.2.0
# Terraform 1.4.6
RUN curl -LO https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip && \
    unzip terraform_1.4.6_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform_1.4.6

# Cleanup
RUN rm terraform_1.2.0_linux_amd64.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the start script
COPY ./start.sh .
RUN chmod +x start.sh

# Set the entrypoint
ENTRYPOINT [ "./start.sh" ]