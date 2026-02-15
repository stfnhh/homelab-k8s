terraform {
  required_version = "~> 1.14"

  backend "s3" {
    bucket       = "stfn-tf-state"
    key          = "homelab/platform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "cert_manager" {
  source = "./modules/cert_manager"

  domain  = var.domain
  zone_id = var.zone_id
  email   = var.email
  region  = var.region

  providers = {
    aws        = aws
    kubernetes = kubernetes
  }
}

module "rancher" {
  source = "./modules/rancher"

  domain = var.domain

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "traefik" {
  source = "./modules/traefik"

  domain = var.domain

  providers = {
    kubernetes = kubernetes
  }
}
