terraform {
  required_version = "~> 1.14"

  backend "s3" {
    bucket       = "stfn-tf-state"
    key          = "homelab/apps/immich.tfstate"
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

# tflint-ignore: terraform_unused_declarations
data "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = "postgres"
  }
}

# tflint-ignore: terraform_unused_declarations
data "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = "redis"
  }
}
