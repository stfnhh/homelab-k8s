resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_22:read-only root filesystem not compatible

  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          name  = "redis"
          image = "redis:alpine@sha256:6cbef353e480a8a6e7f10ec545f13d7d3fa85a212cdcc5ffaf5a1c818b9d3798"

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = false

            capabilities {
              drop = ["ALL", "NET_RAW"]
            }
          }

          readiness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 3
            period_seconds        = 5
            timeout_seconds       = 2
            failure_threshold     = 3
          }

          liveness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 5
          }

          resources {
            requests = {
              cpu    = "25m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}
