# MinIO Namespace
resource "kubernetes_namespace" "minio" {
  metadata {
    name = "minio"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

# Configuration Storage (Longhorn)
resource "kubernetes_persistent_volume_claim" "minio_config" {
  metadata {
    name      = "minio-config"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_secret" "minio_root_password" {
  metadata {
    name      = "minio-root-password"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }
  data = {
    password = random_password.password.result
  }
}

resource "kubernetes_deployment" "minio" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "minio"
      }
    }
    template {
      metadata {
        labels = {
          app = "minio"
        }
      }
      spec {
        security_context {
          fs_group = 1000
        }
        container {
          name  = "minio"
          image = "quay.io/minio/minio:latest"
          image_pull_policy = "Always"

          args  = ["server", "--address", ":9999", "--console-address", ":9001", "/data"]
          port {
            container_port = 9999
            name           = "api"
          }
          port {
            container_port = 9001
            name           = "console"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9001
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          env {
            name  = "MINIO_BROWSER_REDIRECT_URL"
            value = "https://console.minio.${var.domain}"
          }
          env {
            name  = "MINIO_DOMAIN"
            value = "minio.${var.domain}"
          }
          env {
            name  = "MINIO_ROOT_USER"
            value = "admin"
          }
          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_root_password.metadata[0].name
                key  = "password"
              }
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/root/.minio"
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.minio_config.metadata[0].name
          }
        }
        volume {
          name = "data"
          nfs {
            server = var.nfs_server_ip
            path   = "/media/backup"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "minio" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }

  spec {
    selector = {
      app = "minio"
    }
    port {
      name        = "api"
      port        = 9999
      target_port = 9999
    }
    port {
      name        = "console"
      port        = 9001
      target_port = 9001
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "minio_api_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "minio-api"
      namespace = kubernetes_namespace.minio.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`minio.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.minio.metadata[0].name
              port = 9999
            }
          ]
        }
      ]
      tls = {
        secretName = "wildcard-${replace(var.domain, ".", "-")}-tls"
      }
    }
  }
}

resource "kubernetes_manifest" "console_minio_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "console-minio-${replace(var.domain, ".", "-")}"
      namespace = kubernetes_namespace.minio.metadata[0].name
    }
    spec = {
      secretName = "console-minio-${replace(var.domain, ".", "-")}-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "console.minio.${var.domain}"
      ]
    }
  }
}

resource "kubernetes_manifest" "minio_console_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "minio-console"
      namespace = kubernetes_namespace.minio.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`console.minio.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.minio.metadata[0].name
              port = 9001
            }
          ]
        }
      ]
      tls = {
        secretName = "console-minio-${replace(var.domain, ".", "-")}-tls"
      }
    }
  }
}
