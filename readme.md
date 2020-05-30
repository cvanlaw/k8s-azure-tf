# Kubernetes the Hard Way Using Azure and Terrafrom

Complete [Kubernetes the Hard Way][1] using Azure and Terraform.

[1]: https://github.com/kelseyhightower/kubernetes-the-hard-way "Kubernetes the HardWay"

## Getting Started
```
cd src/packer
packer build -var-file=variables.json k8s-controller.packer.json
```