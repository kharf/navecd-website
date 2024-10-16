Update automation is often implemented outside of your cluster through CI scripts. This works well for public packages, but if you want to access private OCI registries or private Helm repositories,
you have to give permissions to your CI platform. This might as well mean to store credentials somewhere accessible by your CI platform.

Your cluster should already have these permissions as it has to be able to fetch images or Helm Charts from private registries/repositories in order to deploy your applications.
Navecd can reuse these permissions for container or Helm Chart updates.

``` cue title="myapp/deployment.cue" hl_lines="21 42"
package myapp

import (
  "github.com/kharf/navecd/schema/component"
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
      replicas: 1
      template: {
        spec: containers: [{
          image: "myimage:2.2" @update(strategy=semver, integration=direct, constraint="2.x", schedule="0 */1 * * * *")
          name:  #Name
          ports: [{
            containerPort: 8080
          }]
        }]
      ...
      }
      ...
    }
  }
}


myRelease: component.#HelmRelease & {
    name:      "my-release"
    namespace: ns.content.metadata.name
    chart: {
        name:    "my-chart"
        repoURL: "oci://my-chart-repository"
        version: "1.0.0"
    } @update(constraint="<2.0.0", schedule="* * * * * *")
    values: {
      foo: "bar"
    }
}
```

`@update()` is a custom CUE build attribute, implemented and understood by Navecd. You can attach it to image fields or helm chart declarations.

## Options

| Name          | Type   | Default  | Description                                                                                                                                                                                                                                                     | Example                         |
|:--------------|:-------|:---------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------|
| `strategy`    | string | "semver" | The versioning schema used to scan for updates. Possible values are "semver".                                                                                                                                                                                   | @update(strategy=semver)        |
| `constraint`  | string | ""       | The version range to be considered during the update process.                                                                                                                                                                                                   | @update(constraint=">= 1.2.3"   |
| `secret`      | string | ""       | The reference to the kubernetes secret containing the repository/registry authentication.                                                                                                                                                                       | @update(secret=mysecret)        |
| `wi`          | string | ""       | WorkloadIdentity is a keyless approach used for repository/registry authentication. Possible values are "gcp", "aws", "azure".                                                                                                                                  | @update(wi=gcp)                 |
| `integration` | string | pr       | The method on how to push updates to the version control system. Possible values are "pr" and "direct".  "pr" tells Navecd to create Github Pull-Requests or Gitlab Merge-Requests. "direct" tells Navecd to push updates directly to the GitOpsProject branch. | @update(integration=direct)     |
| `schedule`    | string | ""       | A string in cron format with an additional seconds field and defines when the target is scanned for updates.                                                                                                                                                    | @update(schedule="* * * * * *") |
