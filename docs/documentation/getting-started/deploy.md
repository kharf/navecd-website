!!! note

    For the purpose of demonstration this guide uses [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) to create a Kubernetes cluster and Github.
    We recommend that beginners follow along with both.

<div class="grid" markdown>

=== "Requirements"

    * Navecd
    * Git
    * Go
    * An empty git repository
    * A GitHub personal access token with repo permissions

</div>

## Create Kind Cluster

``` bash
kind create cluster --name navecd
```

## Initialize a Navecd GitOps Repository

``` bash
mkdir mygitops
cd mygitops
git init
git remote add origin git@github.com:user/mygitops.git
# init Navecd gitops repository as a CUE module
export CUE_REGISTRY=ghcr.io/kharf
navecd init github.com/user/mygitops
go mod init mygitops
navecd verify
git add .
git commit -m "Init navecd"
git push -u origin main
```
See [CUE module reference](https://cuelang.org/docs/reference/modules/#module-path) for valid CUE module paths.

## Install Navecd onto your Kubernetes Cluster

``` bash
navecd install \
  -u git@github.com:user/mygitops.git \
  -b main \
  --name dev \
  -t <token>
git add .
git commit -m "Install navecd"
```

## Deploy a Manifest and a HelmRelease

Get Go Kubernetes Structs and import them as CUE schemas.

!!! tip

    Use CUE modules and provide the following CUE schemas as OCI artifacts.

``` bash
go get k8s.io/api/core/v1
cue get go k8s.io/api/core/v1
cue get go k8s.io/apimachinery/pkg/api/resource
cue get go k8s.io/apimachinery/pkg/apis/meta/v1
cue get go k8s.io/apimachinery/pkg/runtime
cue get go k8s.io/apimachinery/pkg/types
cue get go k8s.io/apimachinery/pkg/watch
cue get go k8s.io/apimachinery/pkg/util/intstr
mkdir infrastructure
touch infrastructure/prometheus.cue
```

Edit `infrastructure/prometheus.cue` and add:

``` cue
package infrastructure

import (
	"github.com/kharf/navecd/schema/component"
	corev1 "k8s.io/api/core/v1"
)

// Public Navecd Manifest Component
ns: component.#Manifest & {
	content: corev1.#Namespace & {
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: {
			name: "monitoring"
		}
	}
}

// Public Navecd HelmRelease Component
prometheusStack: component.#HelmRelease & {
	dependencies: [
    // Navecd automatically generates ids for Components, which are used for dependency constraints.
		ns.id,
	]
	name:      "prometheus-stack"
  // Use namespace name Component reference to reduce redundancy
	namespace: ns.content.metadata.name
	chart: {
		name:    "kube-prometheus-stack"
		repoURL: "https://prometheus-community.github.io/helm-charts"
		version: "58.2.1"
	}
	values: {
		prometheus: prometheusSpec: serviceMonitorSelectorNilUsesHelmValues: false
	}
}
```

See [getting-started](https://github.com/kharf/navecd/blob/main/examples/getting-started/infrastructure/prometheus.cue) example.

``` bash
navecd verify
git add .
git commit -m "feat: install kube-prometheus-stack"
```
