#!/bin/bash

# Basic commands :

# Build :
docker build -t image-name .
# Run for test :
docker run -p 80:8080 -it --name ctn-name image-name
# Enter to container :
docker exec -it ctn-name bash
# Tag :
docker tag image-name TO_BE_DEFINED.azurecr.io/image-name:tag-name
# Login to ACR :
docker login TO_BE_DEFINED.azurecr.io -u USERNAME
# Push To ACR :
docker push TO_BE_DEFINED.azurecr.io/image-name:tag-name

# Azure Pipelines :

# Run the container build agent in host machine :
docker run \
    -e AZP_URL=https://dev.azure.com/TO_BE_DEFINED \
    -e AZP_TOKEN= \
    -e AZP_POOL=TO_BE_DEFINED \
    self-hosted-agent:latest
