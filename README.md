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
<!-- END_TF_DOCS -->

## License

This project is licensed under the MIT License.

## Contributions

Feel free to open issues or submit pull requests to improve this repository.
