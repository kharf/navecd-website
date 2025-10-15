---
title: Home
template: home.html
hide:
  - navigation
  - toc
---
## Embrace GitOps
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
<div class="grid cards" markdown>

-   __Kubernetes Manifests__

    ---

    Deployments, StatefulSets, Pods, ConfigMaps, ..., anything you can deploy to Kubernetes can be deployed with Navecd.

    [Get started!](documentation/getting-started/installation.md)

-   __Helm__

    ---

    Got a Helm Chart? Deploy it with Navecd.

    [See how!](documentation/features/helm.md)

</div>
