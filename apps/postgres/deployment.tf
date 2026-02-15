resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_22:postgres container requires write access and cannot run read-only
  # checkov:skip=CKV_K8S_28:NET_RAW is required
  # checkov:skip=CKV_K8S_22:read-only root filesystem not compatible

  metadata {
    name      = local.name
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.name
      }
    }


    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        container {
          name  = local.name
          image = "pgvector/pgvector:pg18-trixie@sha256:6e0b281a99959919bec7c94718162e75cbbf48e6fd3a5c7529067fa701264082"

          security_context {}

          readiness_probe {
            exec {
              command = ["/usr/bin/pg_isready", "-U", "$(POSTGRES_USER)"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          liveness_probe {
            exec {
              command = ["/usr/bin/pg_isready", "-U", "$(POSTGRES_USER)"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data"
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.secret.metadata[0].name
                key  = "username"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.secret.metadata[0].name
                key  = "password"
              }
            }
          }
          port {
            container_port = 5432
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = "pgdata"
            mount_path = "/var/lib/postgresql"
          }
        }

        volume {
          name = "pgdata"
          persistent_volume_claim {
            claim_name = local.name
          }
        }
      }
    }
  }
}
