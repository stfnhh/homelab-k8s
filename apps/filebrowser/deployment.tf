resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_22: image requires RW filesystem

  metadata {
    name      = "filebrowser"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "filebrowser"
      }
    }

    template {
      metadata {
        labels = {
          app = "filebrowser"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          fs_group        = 1000

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name              = "filebrowser"
          image             = "filebrowser/filebrowser:v2.49.0@sha256:e9ef7570b2e4110e9842f2e004f2aaac246e54e7fef2b3b9f4352a3a1bb04508"
          image_pull_policy = "Always"

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = false

            capabilities {
              drop = ["ALL", "NET_RAW"]
            }
          }

          env {
            name  = "TZ"
            value = "America/New_York"
          }

          port {
            container_port = 80
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

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "data"
            mount_path = "/srv"
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
