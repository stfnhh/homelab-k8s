# Home Lab Kubernetes Configuration

## Overview

This repository contains the Kubernetes (K8s) configuration for a home lab environment, provisioned and managed using **Terraform**. The cluster is designed to run self-hosted applications and services efficiently on a small-scale commodity infrastructure.

## Cluster Architecture

This Kubernetes cluster is deployed across three **HP 600 G2 Micro Computer Mini Tower PCs** running **Rocky Linux 9**, with the following configuration:

- **1 Master/Worker Node**
  - **CPU:** Intel Quad Core i5-6500T
  - **RAM:** 16GB DDR4
  - **Storage:** 256GB NVMe SSD + 2TB HDD
- **2 Worker Nodes**
  - **CPU:** Intel Quad Core i5-6500T
  - **RAM:** 16GB DDR4
  - **Storage:** 256GB NVMe SSD + 2TB HDD

The cluster is designed to handle containerized workloads, providing scalability within a home lab environment.

## Host Setup

1. **Update and Upgrade Packages:**
   ```bash
   sudo dnf update -y
   ```
2. **Install Required Packages:**
   ```bash
   sudo dnf install -y epel-release git curl vim wget iscsi-initiator-utils nfs-utils
   sudo shutdown -r now
   ```
3. **Disable Firewall:**
   ```bash
   sudo systemctl stop firewalld
   sudo systemctl disable firewalld
   ```
4. **Disable Swap (Required for Kubernetes):**
   ```bash
   sudo swapoff -a
   sudo sed -i '/swap/d' /etc/fstab
   ```
5. **Configure HDD:**
   ```bash
   fdisk # follow prompts
   mkfs -t ext4 /dev/sda1
   mkdir -p /mnt/storage
   mount /dev/sda1 /mnt/storage

   # edit fstab file to mount permanently 
   ```
6. **Install and Configure K3S**
   ```bash
   curl -sfL https://get.k3s.io | K3S_URL="https://10.0.0.200:6443" K3S_TOKEN="${K3S_TOKEN}" sh -
   ```

## Applications & Services

This cluster is configured to run the following services:

- **Aria2** - A lightweight multi-protocol & multi-source download utility.
- **Cert-Manager** - Automated TLS certificate management.
- **FileGator** - A web-based file manager for self-hosted solutions.
- **IAM** - Identity and access management for AWS, used by Cert-Manager for Route53 access.
- **Jellyfin** - A media server for streaming movies, TV shows, and music.
- **Longhorn** - A distributed block storage solution.
- **Minio** - High-performance object storage.
- **Photoprism** - AI-powered photo management.
- **Rancher** - Kubernetes cluster management and orchestration.
- **Traefik** - Reverse proxy and ingress controller.

## Terraform Docs

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.11 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.23 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.8 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.11 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.23 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.7 |
## Modules

No modules.
## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.iam_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.iam_user_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.longhorn](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.rancher](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_deployment.ariang](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.filegator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.jellyfin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.minio](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.photoprism](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_manifest.ariang_ingressroute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.cluster_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.console_minio_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.filegator_ingressroute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.jellyfin_ingressroute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.minio_api_ingressroute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.minio_console_ingressroute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.photoprism_ingressroute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.rancher_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.traefik_dashboard](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.wildcard_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.ariang](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.filegator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.jellyfin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.longhorn](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.minio](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.photoprism](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_persistent_volume_claim.aria2_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.filegator_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.jellyfin_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.minio_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.photoprism_database](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.photoprism_originals](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.photoprism_storage](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_secret.minio_root_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.photoprism_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.route53_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.ariang](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.filegator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.jellyfin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.minio](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.photoprism](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | Domain | `string` | n/a | yes |
| <a name="input_email"></a> [email](#input\_email) | Email | `string` | n/a | yes |
| <a name="input_nfs_server_ip"></a> [nfs\_server\_ip](#input\_nfs\_server\_ip) | IP of NFS server | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-east-1"` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 Zone ID | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rancher_password"></a> [rancher\_password](#output\_rancher\_password) | Rancher Password |
<!-- END_TF_DOCS -->

## License

This project is licensed under the MIT License.

## Contributions

Feel free to open issues or submit pull requests to improve this repository.
