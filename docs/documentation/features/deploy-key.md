When installing Navecd on Github or GitLab, Navecd will create a Deploy Key with the provided Access Token and store the private SSH key in a Kubernetes Secret.

## Rotation

In order to rotate the Deploy Key, you have to manually delete the Kubernetes Secret and run the installation command again.

The secret resides in the Controller Namespace and is prefixed with "vcs-auth" and suffixed with the GitOpsProject name.

``` bash
kubectl delete -n navecd-system secret vcs-auth-myproject
```
