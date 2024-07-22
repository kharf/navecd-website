Declcd has first class support for Helm. It can install and upgrade Charts.
Drift detection is enabled by default and implemented by patching Helm with Server-Side Apply (SSA).

## Install Helm Chart

To install a Helm Chart, declare a desired HelmRelease Component:

``` cue
package myapp

import (
  "github.com/kharf/declcd/schema/component"
)

myRelease: component.#HelmRelease & {
    name:      "my-release"
    namespace: ns.content.metadata.name
    chart: {
        name:    "my-chart"
        repoURL: "oci://my-chart-repository"
        version: "x.x.x"
    }
    values: {
      foo: "bar"
    }
}
```

## Private Repositories

Private Repositories are supported either through [Workload Identity](workload-identity.md) or Kubernetes Secrets.

A Secret can be referenced as follows:

``` cue hl_lines="14 15 16 17 18"
package myapp

import (
  "github.com/kharf/declcd/schema/component"
)

myRelease: component.#HelmRelease & {
    name:      "my-release"
    namespace: ns.content.metadata.name
    chart: {
        name:    "my-chart"
        repoURL: "oci://my-chart-repository"
        version: "x.x.x"
        auth: secretRef: {
          name: "secret-name"
          // Can not be cross namespace. Field wil be deleted in upcoming versions.
          namespace: "secret-namespace"
        }
    }
    values: {
      foo: "bar"
    }
}
```

## Custom Resource Definitions (CRDs)

Helm 3 supports installation of CRDs through a `crds` directory inside a Chart, but it does not support upgrades/deletions.
See [reason](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations).

However, CRD upgrade is supported by Declcd and can be enabled:

!!! info

    Declcd never deletes CRDs contained in a Chart. It only handles installations and upgrades.

``` cue hl_lines="17"
package myapp

import (
  "github.com/kharf/declcd/schema/component"
)

myRelease: component.#HelmRelease & {
    name:      "my-release"
    namespace: ns.content.metadata.name

    chart: {
        name:    "my-chart"
        repoURL: "oci://my-chart-repository"
        version: "x.x.x"
    }

    crds: allowUpgrade: true

    values: {
      foo: "bar"
    }
}
```

## Patches / Post Rendering

Patches allow to manipulate rendered manifests before they are installed or upgraded. 
Manifests are identified by their GVK(Group/Version/Kind), Name and Namespace for namespaced manifests.

``` cue hl_lines="23-35"
package myapp

import (
  "github.com/kharf/declcd/schema/component"
)

myRelease: component.#HelmRelease & {
    name:      "my-release"
    namespace: ns.content.metadata.name

    chart: {
        name:    "my-chart"
        repoURL: "oci://my-chart-repository"
        version: "x.x.x"
    }

    crds: allowUpgrade: true

    values: {
      foo: "bar"
    }

    patches: [
      #deployment & {
        apiVersion: "apps/v1"
        kind: "Deployment"
        metadata: {
          name:      "deployment-from-chart"
          namespace: ns.content.metadata.name
        }
        spec: {
          replicas: 2 @ignore(conflict)
        }
      },
    ]
}
```

Noticed the `@ignore(conflict)` build attribute at line 32?
Patches can also be used to "flag" manifest fields of Helm Chart templates.

Read more here: [Conflict Management](conflicts.md)
