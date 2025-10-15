## What is GitOps?

GitOps is a way of implementing Continuous Deployment for cloud native applications by having a repository that contains declarative descriptions of the desired infrastructure and applications
and an automated process to reconcile the production environment with the desired state in the repository.

## Why Navecd?

Traditional GitOps tools often rely on YAML for configuration, which can lead to verbosity and complexity.
Navecd leverages [CUE](https://cuelang.org/), a type safe configuration language with a more concise and expressive syntax and the benefits of general-purpose programming languages,
making it easier to define and maintain your desired cluster state.

Navecd adheres to the GitOps Principles:

<div class="grid cards" markdown>

-   __Declarative__

    ---

    Navecd integrates [CUE](https://cuelang.org/) natively - A type safe configuration language with the benefits of general-purpose programming languages

-   __Versioned and Immutable__

    ---

    OCI repositories as the source of truth for defining the desired system state

-   __Pulled Automatically__

    ---

    Navecd automatically pulls the desired state declarations, written as CUE values, from OCI repositories

-   __Continuously Reconciled__

    ---

    Navecd is a Kubernetes Controller, which continuously observes actual system state and applies the desired state

</div>

## Deploy anything

Deployments, StatefulSets, Pods, ConfigMaps, ..., anything you can deploy to Kubernetes can be deployed with Navecd.
Got a Helm Chart? Deploy it with Navecd.

## Basics of Navecd

Navecd does not enforce any kind of repository structure, but there is one constraint for declarations of cluster state.
Every top-level CUE value in a package, which is not hidden and not a [Definition](https://cuelang.org/docs/tour/basics/definitions/), has to be what Navecd calls a *Component*.
Navecd Components effectively describe the desired cluster state and currently exist in two forms: *Manifests* and *HelmReleases*.
A *Manifest* is a typical [Kubernetes Object](https://kubernetes.io/docs/concepts/overview/working-with-objects/), which you would normally describe in yaml format.
A *HelmRelease* is an instance of a [Helm](https://helm.sh/docs/intro/using_helm/) Chart.
All Components share the attribute to specify Dependencies to other Components. This helps Navecd to identify the correct order in which to apply all objects onto a Kubernetes cluster.
See [schema](https://github.com/kharf/navecd/blob/main/schema/component/schema.cue).

## Next Steps
Get started with [Navecd](getting-started/installation.md).
