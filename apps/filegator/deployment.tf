resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_22: container requires write access and cannot run read-only
  # checkov:skip=CKV_K8S_20: image requires privilege escalation
  # checkov:skip=CKV_K8S_28: NET_RAW is required 
  # checkov:skip=CKV_K8S_22: read-only root filesystem not compatible

  metadata {
    name      = "filegator"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "filegator"
      }
    }

    template {
      metadata {
        labels = {
          app = "filegator"
        }
      }

      spec {
        container {
          name              = "filegator"
          image             = "maxime1907/filegator:latest@sha256:4997a9e44b411a11aa51d28685a8b59166445e18a1c52a667b3cedf7b96da6a9"
          image_pull_policy = "Always"

          security_context {}

          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          env {
            name  = "TZ"
            value = "America/New_York"
          }

          port {
            container_port = 80
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.persistent_volume_claim.metadata[0].name
          }
        }

        volume {
          name = "data"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Media"
          }
        }
      }
    }
  }
}
