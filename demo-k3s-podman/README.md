# Demo using k3s and Podman

This demo uses k3s as a kubernetes cluster.  By default, k3s uses `containerd` for the container engine on the worker nodes. This demo, will use `podman` as the container engine for the node running KrustletCRI.

The k3s cluster will be deployed in Microsoft Azure.

## Requirements

The following resources are required to use this demo.

- An Azure subscription. This is where the cluster virtual machines will be deployed.
- Azure CLI, +v2.32.0
- Terraform, +v1.1.3 on local machine. Terraform is used to provision the environment in Azure.
- SSH keys on local machine. This will be used to authenticate to the virtual machines in Azure when establishing an SSH connection. 

> This has been tested and verified using `Ubuntu 21.10`.

## Deploy Azure Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

