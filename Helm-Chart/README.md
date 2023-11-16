## Prerequisites

### Install Keda on the cluster
```sh
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda
```
### Set the devops namespace
```sh
k create ns devopsagent
k config set-context --current --namespace=devopsagent
```

## Manage Agent Deployment

### Prepare a new agent deployment
- Create a new file `<project-name>-<env>-values.yaml` in the `devops-agent` folder.
- Use the command `echo -n '<azp_pool_name>' | base64` to obtain the value and set it for `data.azp_pool`.
- If you deploy with Keda, add the `poolID` value.
- If you deploy without Keda, rename `keda.yaml` to `_keda.yaml`.

### Manage with Helm
```sh
helm install <project-code>-<env> devops-agent/ --values devops-agent/<Project-Name>/<project-name>-<env>-values.yaml
helm upgrade <project-code>-<env> devops-agent/ --values devops-agent/<Project-Name>/<project-name>-<env>-values.yaml
helm list
helm uninstall <project-code>-<env>
```

Customize the values in angle brackets (<) according to the specific project and environment.

### Parameters

| Value                 | Description                                                                                       |
|-----------------------|---------------------------------------------------------------------------------------------------|
| `labels.app`          | The name of the deployed application.                                                            |
| `image.repository`    | The name of the Azure Container Registry (ACR) + the image name of the runner.                    |
| `image.tag`           | The specific tag of the runner image.                                                             |
| `data.azp_pool`       | The name of the agent pool encoded in Base64.                                                     |
| `maxReplicaCount`     | (Only for Keda deployments)                                                                      |
| `poolID`              | (Only for Keda deployments) The ID of the agent pool used by Keda to scale the pipelines.        |
