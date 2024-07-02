Declcd deployed on Azure AKS, AWS EKS or GCP GKE can be configured to use Workload Identity to access the corresponding cloud container registries.

## Azure AKS

!!! info

    See [Azure Documentation](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) to learn about how to setup Azure Workload Identity.

Annotate the Kubernetes Service Account used for your GitOpsProject with the Microsoft Entra application
client ID:

!!! note

    If no Service Account is provided via the GitOpsProject spec, Declcd uses the ServiceAccount from the Controller Deployment.

``` cue
primaryServiceAccount: component.#Manifest & {
  dependencies: [ns.id]
  content: {
    apiVersion: "v1"
    kind:       "ServiceAccount"
    metadata: {
      name:      "project-controller-primary"
      namespace: ns.content.metadata.name
      annotations: "azure.workload.identity/client-id": "<client id>"
		}
	}
}
```

Label Declcd pods to use Workload Identity:

!!! note

    The Declcd Controller Deployment value name contains the shard name when initialized through the Declcd CLI. The default name is "primaryProjectControllerDeployment".

``` cue title="declcd/patch.cue"
package declcd

import (
  "github.com/kharf/declcd/schema/component"
)

primaryProjectControllerDeployment: component.#Manifest & {
  content: {
    spec: template: metadata: labels: {
      "azure.workload.identity/use": "true"
    }
  }
}
```

Update your Helm Release to use Workload Identity:

``` cue
package myapp

import (
	"github.com/kharf/declcd/schema/component"
	"github.com/kharf/declcd/schema/workloadidentity"
)

release: component.#HelmRelease & {
  dependencies: [ns.id]
  name:      "myapp"
  namespace: ns.content.metadata.name
  chart: {
    name:    "myapp"
    repoURL: "oci://myapp.azurecr.io"
    version: "1.0.0"
    auth:    workloadidentity.#Azure
  }
}
```
