terraform {
  required_version = "~> 1.14"

  backend "s3" {
    bucket       = "stfn-tf-state"
    key          = "homelab/apps/filegator.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
