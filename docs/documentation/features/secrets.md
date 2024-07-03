Secrets, encrypted or unencrypted, should not reside in Git and are best managed by a dedicated secret manager.

Declcd integrates well with the [External Secrets Operator](https://external-secrets.io/).

## Example

``` cue title="infrastructure/eso.cue"
package externalsecrets

import (
	"github.com/kharf/declcd/schema/component"
)

_name: "external-secrets"

ns: component.#Manifest & {
  apiVersion: "v1"
  kind: "Secret"
  metadata: name: _name
}

release: component.#HelmRelease & {
	dependencies: [
		ns.id,
	]
	name:      _name
	namespace: ns.content.metadata.name
	chart: {
		name:    _name
		repoURL: "oci://ghcr.io/external-secrets/charts"
		version: "x.x.x"
	}
}
```

``` cue title="infrastructure/store.cue"
package externalsecrets

import (
	"github.com/kharf/declcd/schema/component"
  // go get github.com/external-secrets/external-secrets/apis/externalsecrets/v1beta1
  // cue get go github.com/external-secrets/external-secrets/apis/externalsecrets/v1beta1
	"github.com/external-secrets/external-secrets/apis/externalsecrets/v1beta1"
)

storeServiceAccount: component.#Manifest & {
  dependencies: [
    ns.id,
  ]
  content: {
    apiVersion: "v1"
    kind:       "ServiceAccount"
    metadata: {
      name:      "secret-store"
      namespace: ns.content.metadata.name
    }
  }
}

storeRole: component.#Manifest & {
  content: {
    apiVersion: "rbac.authorization.k8s.io/v1"
    kind:       "ClusterRole"
    metadata: {
      name: "secret-store"
    }
    rules: [{
      apiGroups: [""]
      resources: ["secrets"]
      verbs: [
        "get",
        "list",
        "watch",
      ]
    }, {
      apiGroups: ["authorization.k8s.io"]
      resources: ["selfsubjectrulesreviews"]
      verbs: ["create"]
    }]
  }
}

storeRoleBinding: component.#Manifest & {
  dependencies: [
    secretsNs.id,
    storeRole.id,
    storeServiceAccount.id,
  ]
  content: {
    apiVersion: "rbac.authorization.k8s.io/v1"
    kind:       "RoleBinding"
    metadata: {
      name:      "secret-store"
      namespace: secretsNs.content.metadata.name
    }
    roleRef: {
      apiGroup: "rbac.authorization.k8s.io"
      kind:     storeRole.content.kind
      name:     storeRole.content.metadata.name
    }
    subjects: [{
      kind:      storeServiceAccount.content.kind
      name:      storeServiceAccount.content.metadata.name
      namespace: storeServiceAccount.content.metadata.namespace
    }]
  }
}

store: component.#Manifest & {
  dependencies: [
    storeServiceAccount.id,
  ]
  content: v1beta1.#SecretStore & {
    apiVersion: "external-secrets.io/v1beta1"
    kind:       "SecretStore"
    metadata: {
      name:      "secret-store"
      namespace: ns.content.metadata.name
    }
    spec: provider: kubernetes: {
      remoteNamespace: "secrets"
      server: {
        caProvider: {
          type: "ConfigMap"
          name: "kube-root-ca.crt"
          key:  "ca.crt"
        }
      }
      auth: serviceAccount: name: storeServiceAccount.content.metadata.name
    }
  }
}

secrets: component.#Manifest & {
  dependencies: [
    store.id,
  ]
  content: v1beta1.#ExternalSecret & {
    apiVersion: "external-secrets.io/v1beta1"
    kind:       "ExternalSecret"
    metadata: {
      name:      "secrets"
      namespace: ns.content.metadata.name
    }
    spec: {
      refreshInterval: "1h"
      secretStoreRef: {
        kind: "SecretStore"
        name: store.content.metadata.name
      }
      target: {
        name: secretsNs.content.metadata.name
      }
      data: [{
        secretKey: "username"
        remoteRef: {
          key:      "database-credentials"
          property: "username"
        }
      }, {
      secretKey: "password"
      remoteRef: {
        key:      "database-credentials"
        property: "password"
      }
      }]
		}
	}
}

secretsNs: component.#Manifest & {
  content: {
    apiVersion: "v1"
    kind: "Secret"
    metadata: name: "secrets"
  } 
}
```
