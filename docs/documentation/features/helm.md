Declcd has first class support for Helm. It can install and upgrade Charts.
Drift detection is enabled by default and implemented by patching Helm with Server-Side Apply (SSA).

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
