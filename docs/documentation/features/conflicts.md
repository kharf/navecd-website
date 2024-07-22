Declcd uses [Server-Side Apply](https://kubernetes.io/docs/reference/using-api/server-side-apply/) to maintain cluster states and SSA provides a mechanism to track changes to a manifest's fields, which is called `Field Management`. Declcd takes Ownership of all manifest's fields declared in Git.
This makes Declcd a `Field Manager`.

Any change to Declcd managed fields will be overwritten by Declcd and if you commit to using GitOps as your way to deploy to Kubernetes, then manual changes to your cluster are an anti pattern.
But there are cases where Field Managers in your cluster try to take over management of certain fields.
The most prominent situation probably is a Horizontal Pod Autoscaler mutating the replicas count.
In order to avoid fighting over the replicas count, you can tell Declcd to ignore conflicting fields, so that the competing manager can take over. 

``` cue title="myapp/deployment.cue" hl_lines="18"
package myapp

import (
  "github.com/kharf/declcd/schema/component"
)

deployment: component.#Manifest & {
  content: {
    apiVersion: "apps/v1"
    kind:       "Deployment"
    metadata: {
      name:      "my-deployment"
      namespace: ns.content.metadata.name
      labels:    _primaryLabels
    }
    spec: {
      selector: matchLabels: _primaryLabels
      replicas: 1 @ignore(conflict)
  ...
    }
  }
}
```

`@ignore(conflicts)` is a custom CUE build attribute, implemented and understood by Declcd. You can attach it to fields or declarations to resolve field conflicts.
