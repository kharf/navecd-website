[Sharding](multi-tenancy.md) is used to distribute workload by installing multiple Navecd Controllers and
Navecd uses [Leases](https://kubernetes.io/docs/concepts/architecture/leases/) to make sure that there is only one running Controller per Shard.

While that works for most cases, sometimes it is desired to have backup instances running on different nodes to reduce downtime in case of node failures.
You can use [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity)
and increase the replica count of your Navecd Controllers to counter that situation:

``` cue title="navecd/primary_system.cue" hl_lines="19"
package navecd

import (
  "github.com/kharf/navecd/schema/component"
)

primaryProjectControllerDeployment: component.#Manifest & {
  ...
  content: {
    apiVersion: "apps/v1"
    kind:       "Deployment"
    metadata: {
      name:      "project-controller-primary"
      namespace: ns.content.metadata.name
      labels:    _primaryLabels
    }
    spec: {
      selector: matchLabels: _primaryLabels
      replicas: 2
  ...
    }
  }
}
```

``` cue title="navecd/ha.cue""
package navecd

import (
  "github.com/kharf/navecd/schema/component"
)

primaryProjectControllerDeployment: component.#Manifest & {
  content: spec: template: spec: affinity: podAntiAffinity: {
    requiredDuringSchedulingIgnoredDuringExecution: [{
      labelSelector: matchExpressions: [{
        key:      _shardKey
        operator: "In"
        values: ["primary"]
      }]
      topologyKey: "kubernetes.io/hostname"
    }]
  }
}
```
