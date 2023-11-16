#!/bin/bash

# Basic commands :

# Build :
docker build -t image-name .
# Run for test :
docker run -p 80:8080 -it --name ctn-name image-name
# Enter to container :
docker exec -it ctn-name bash
# Tag :
docker tag image-name acragentsdevops.azurecr.io/image-name:tag-name
# Login to ACR :
docker login acragentsdevops.azurecr.io -u USERNAME
# Push To ACR :
docker push acragentsdevops.azurecr.io/image-name:tag-name

# Azure Pipelines :

# Run the container build agent in host machine :
docker run \
    -e AZP_URL=https://dev.azure.com/amcs-apps \
    -e AZP_TOKEN= \
    -e AZP_POOL=k8s-agent-pool \
    self-hosted-agent:latest
