# Home Lab Kubernetes Configuration

## Overview

This repository contains the Kubernetes (K8s) configuration for a home lab environment, provisioned and managed using **Terraform**. The cluster is designed to run self-hosted applications and services efficiently on a small-scale commodity infrastructure.

## Cluster Architecture

This Kubernetes cluster is deployed across three **HP 600 G2 Micro Computer Mini Tower PCs** running **Rocky Linux 9**, with the following configuration:

**1 Master/Worker Node**

  - **CPU:** Intel Quad Core i5-6500T
  - **RAM:** 16GB DDR4
  - **Storage:** 256GB NVMe SSD + 2TB HDD

**2 Worker Nodes**

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

This cluster is configured to run the following applications & services:

**Services**

- **[Cert-Manager](platform/modules/cert-manager)** - Automated TLS certificate management.
- **[Longhorn](platform/modules/longhorn)** - A distributed block storage solution.
- **[Rancher](platform/modules/rancher)** - Kubernetes cluster management and orchestration.
- **[Traefik](platform/modules/traefik)** - Reverse proxy and ingress controller.

**Applications**

- **[Ariang](apps/ariang)** - A lightweight multi-protocol & multi-source download utility.
- **[FileGator](apps/filegator)** - A web-based file manager for self-hosted solutions.
- **[Jellyfin](apps/jellyfin)** - A media server for streaming movies, TV shows, and music.
- **[Kopia](apps/kopia)** - A fast, secure, deduplicating backup solution for files, servers, and containers.
- **[Redis](apps/redis)** - An in-memory key-value datastore used for caching, queues, and real-time data.
- **[Postgres](apps/postgres)** - A powerful open-source relational database known for reliability and extensibility.
- **[Peanut](apps/peanut)** - A lightweight NUT (Network UPS Tools) monitor providing real-time UPS status and metrics.
- **[Immich](apps/immich)** - AI-powered photo management.

## License

This project is licensed under the MIT License.

## Contributions

Feel free to open issues or submit pull requests to improve this repository.
