Navecd deployed on Azure AKS, AWS EKS or GCP GKE can be configured to use Workload Identity to access the corresponding cloud container registries.

## Azure AKS

!!! info

    See [Azure Documentation](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) to learn about how to setup Azure Workload Identity.

Annotate the Kubernetes Service Account used for your GitOpsProject with the Microsoft Entra application
client ID:

!!! note

    If no Service Account is provided via the GitOpsProject spec, Navecd uses the ServiceAccount from the Controller Deployment.

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

Label Navecd pods to use Workload Identity:

!!! note

    The Navecd Controller Deployment value name contains the shard name when initialized through the Navecd CLI. The default name is "primaryProjectControllerDeployment".

``` cue title="navecd/patch.cue"
package navecd

import (
  "github.com/kharf/navecd/schema/component"
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

``` cue hl_lines="16"
package myapp

import (
  "github.com/kharf/navecd/schema/component"
  "github.com/kharf/navecd/schema/workloadidentity"
)

release: component.#HelmRelease & {
  dependencies: [ns.id]
  name:      "myapp"
  namespace: ns.content.metadata.name
  chart: {
    name:    "myapp"
    repoURL: "oci://myfakeregistry.azurecr.io"
    version: "1.0.0"
    auth:    workloadidentity.#Azure
  }
}
```

Update your GitOpsProject to use Workload Identity:

``` cue hl_lines="26"
package myapp

import (
  "github.com/kharf/navecd/schema/component"
  "github.com/kharf/navecd/schema/workloadidentity"
)

project: component.#Manifest & {
	dependencies: [
		crd.id,
		ns.id,
	]
	content: {
		apiVersion: "gitops.navecd.io/v1beta1"
		kind:       "GitOpsProject"
		metadata: {
			name:      "mygitops"
			namespace: "navecd-system"
			labels: _primaryLabels
		}
		spec: {
			url:                 "oci://myfakeregistry.azurecr.io"
			ref:                 "latest"
			pullIntervalSeconds: 5
			suspend:             false
			auth: workloadidentity.#Azure
		}
	}
}
```

## AWS EKS

!!! info

    See [AWS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) to learn about how to setup EKS Workload Identity (EKS Pod Identities).

Update your Helm Release to use Workload Identity:

``` cue hl_lines="16"
package myapp

import (
  "github.com/kharf/navecd/schema/component"
  "github.com/kharf/navecd/schema/workloadidentity"
)

release: component.#HelmRelease & {
  dependencies: [ns.id]
  name:      "myapp"
  namespace: ns.content.metadata.name
  chart: {
    name:    "myapp"
    repoURL: "oci://myfakeregistry.dkr.ecr.eu-north-1.amazonaws.com"
    version: "1.0.0"
    auth:    workloadidentity.#AWS
  }
}
```

Update your GitOpsProject to use Workload Identity:

``` cue hl_lines="26"
package myapp

import (
  "github.com/kharf/navecd/schema/component"
  "github.com/kharf/navecd/schema/workloadidentity"
)

project: component.#Manifest & {
	dependencies: [
		crd.id,
		ns.id,
	]
	content: {
		apiVersion: "gitops.navecd.io/v1beta1"
		kind:       "GitOpsProject"
		metadata: {
			name:      "mygitops"
			namespace: "navecd-system"
			labels: _primaryLabels
		}
		spec: {
			url:                 "oci://myfakeregistry.azurecr.io"
			ref:                 "latest"
			pullIntervalSeconds: 5
			suspend:             false
			auth: workloadidentity.#AWS
		}
	}
}
```

## GCP GKE

!!! info

    See [GCP Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) to learn about how to setup GKE Workload Identity (IAM principal identifiers).

Update your Helm Release to use Workload Identity:

``` cue hl_lines="16"
package myapp

import (
  "github.com/kharf/navecd/schema/component"
  "github.com/kharf/navecd/schema/workloadidentity"
)

release: component.#HelmRelease & {
  dependencies: [ns.id]
  name:      "myapp"
  namespace: ns.content.metadata.name
  chart: {
    name:    "myapp"
    repoURL: "oci://europe-west4-docker.pkg.dev/myfakeregistry/charts"
    version: "1.0.0"
    auth:    workloadidentity.#GCP
  }
}

```
Update your GitOpsProject to use Workload Identity:

``` cue hl_lines="26"
package myapp

import (
  "github.com/kharf/navecd/schema/component"
  "github.com/kharf/navecd/schema/workloadidentity"
)

project: component.#Manifest & {
	dependencies: [
		crd.id,
		ns.id,
	]
	content: {
		apiVersion: "gitops.navecd.io/v1beta1"
		kind:       "GitOpsProject"
		metadata: {
			name:      "mygitops"
			namespace: "navecd-system"
			labels: _primaryLabels
		}
		spec: {
			url:                 "oci://myfakeregistry.azurecr.io"
			ref:                 "latest"
			pullIntervalSeconds: 5
			suspend:             false
			auth: workloadidentity.#GCP
		}
	}
}
```

