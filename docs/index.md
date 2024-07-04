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

    Utilizing [CUE](https://cuelang.org/) - A type safe configuration language with the benefits of general-purpose programming languages

-   __Versioned and Immutable__

    ---

    Using Git as the source of truth for defining the desired system state

-   __Pulled Automatically__

    ---

    Declcd automatically pulls the desired state declarations, written as CUE values, from Git

-   __Continuously Reconciled__

    ---

    Declcd is a Kubernetes Controller, which continuously observes actual system state and applies the desired state

</div>




## Deploy anything
<div class="grid cards" markdown>

-   __Kubernetes Manifests__

    ---

    Deployments, StatefulSets, Pods, ConfigMaps, ..., anything you can deploy to Kubernetes can be deployed with Declcd.

    Just push to Git and let Declcd do the work from inside your Cluster!

    [Get started!](documentation/getting-started/installation.md)

-   __Helm__

    ---

    Got a Helm Chart? Deploy it with Declcd.

    [See how!](documentation/features/helm.md)

</div>
