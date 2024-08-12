# Using the EKS Kubernetes Cluster

## Overview

For the sake of simplicity, a single Kubernetes cluster is created. K8s security/access controls can then be used to
limit access to resources. This is simpler than managing multiple AWS accounts and EKS clusters and, if well configured,
as secure.

## `kubectl` Access

Install the latest version of the `aws` command (e.g. `brew install awscli` or `pip/apt install aws-cli`, etc.) It must
be a modern version (e.g. >=2.20) - older versions are not supported.

Test access to EKS. With the appropriate profile/credentials, run:

```shell
$ aws eks describe-cluster --name showcase-main
```

To repeat: ensure the correct credentials (via profile or specifying AWS keys) are set in the environment first. Unlike
the infra_management project, they must be credentials for the AWS account in which the EKS cluster is hosted, not the
management account, e.g. the `Prod` account.

If an EKS cluster description is shown, proceed. Otherwise, configure AWS CLI access such that the above command works.

Create a `kubeconfig` (granting same AWS privileges as above aws command):

```shell
$ aws eks update-kubeconfig --name showcase-main
```

This command can be repeated should anything change in the configuration that must be updated into the kubeconfig.
