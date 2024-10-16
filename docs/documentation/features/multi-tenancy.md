The usual GitOps setup consists of a single GitOpsProject and a single GitOps Controller, but Navecd supports Multi-Tenancy, where a system evolves around multiple Git repositories.
For example a company wants to split responsibilities to different teams. A platform team could maintain Navecd and all the infrastructure necessary to run a cluster with independant tenants,
while each tenant could maintain its own state of applications.

Navecd uses the concept of Sharding. Every Navecd Controller instance forms a Shard and GitOpsProjects are assigned to Shards.

![Arch](../../assets/navecd-platform-arch.png)

## Single-Sharded

By default Navecd is single-sharded, but multiple GitOpsProjects can be assigned to the same Shard:

!!! info

    The default Controller Service Account has Cluster Admin rights.
    You can limit a tenant's permissions by assigning a custom Service Account to the tenant's GitOpsProject. 

``` cue title="projects.cue" hl_lines="47"
package navecd

import (
  "github.com/kharf/navecd/schema/component"
)

foundation: component.#Manifest & {
  dependencies: [
    crd.id,
    ns.id,
  ]
  content: {
    apiVersion: "gitops.navecd.io/v1beta1"
    kind:       "GitOpsProject"
    metadata: {
      name:      "foundation"
      namespace: "navecd-system"
      labels:    {
        "navecd/shard":   "primary"
      }
    }
    spec: {
      branch:              "main"
      pullIntervalSeconds: 30
      suspend:             false
      url:                 "git@github.com:user/platform.git"
    }
  }
}

tenant: component.#Manifest & {
  dependencies: [
    crd.id,
    ns.id,
  ]
  content: {
    apiVersion: "gitops.navecd.io/v1beta1"
    kind:       "GitOpsProject"
    metadata: {
      name:      "tenant"
      namespace: "navecd-system"
      labels:    {
        "navecd/shard":   "primary"
      }
    }
    spec: {
      serviceAccountName: "tenant"
      branch:              "main"
      pullIntervalSeconds: 30
      suspend:             false
      url:                 "git@github.com:user/tenant.git"
    }
  }
}
```

## Multi-Sharded

!!! info

     The default shard name is "primary" when initializing/installing. You can provide a different one via the "--shard" flag.

``` bash
# platform shard
navecd init github.com/user/mygitops
navecd install \
  -u git@github.com:user/platform.git \
  -b main \
  --name dev \
  -t <token>

# tenant shard
navecd init github.com/user/mygitops --shard tenant --secondary
navecd install \
  -u git@github.com:user/tenant.git \
  -b main \
  --name dev \
  -t <token> \
  --shard tenant
```

A complete example can be found here: [Navecd Platform Example](https://github.com/kharf/navecd-platform-example).
