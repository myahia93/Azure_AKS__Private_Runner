# AZURE-AKS-PRIVATE-RUNNER

This repository contains the following folders and files:

## Architecture

The `Architecture` folder contains the Azure Architecture of the Kubernetes Cluster.

## Docker

The `Docker` folder contains Dockerfiles for the runner images. These Dockerfiles define the environment and dependencies required for executing pipelines in Azure DevOps.

## Helm-Chart

The `Helm-Chart` folder includes template and configuration files for the DevOps agents and autoscaling using Keda. These files provide the necessary configuration for deploying and scaling the agents within the Kubernetes cluster using Helm.

## Terraform

The `Terraform` folder contains the code necessary to deploy the Azure Kubernetes Service (AKS) and Azure Container Registry (ACR). 

## Pipelines

The `azure-pipelines-terraform.yml` file is a YAML file for continuous integration and continuous delivery of the Terraform IaC.
The `azure-pipelines-test.yml` file is a YAML file for testing Azure DevOps pipelines on multiple containers.

## Thesis

The `Thesis` folder contains my Master 1 thesis written in French for my school Efrei Paris.
