resource "kubernetes_deployment" "deployment" {
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
        security_context {
          fs_group = 1000
        }

        container {
          name              = local.name
          image             = "kopia/kopia:0.22.2@sha256:883b0f357cafbf2d9ea828a1336951fa8998cf6b63ea55fdf57b1f22447e7f47"
          image_pull_policy = "Always"

          security_context {
            run_as_user               = 1000
            run_as_group              = 1000
            read_only_root_filesystem = true

            capabilities {
              drop = ["ALL"]
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 51515
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 51515
            }
            initial_delay_seconds = 10
            period_seconds        = 20
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          args = [
            "server", "start",
            "--address=0.0.0.0:51515",
            "--disable-csrf-token-checks",
            "--without-password",
            "--insecure"
          ]

          port {
            container_port = 51515
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/config"
          }
          volume_mount {
            name       = "photos"
            mount_path = "/photos"
          }
          volume_mount {
            name       = "logs"
            mount_path = "/app/logs"
          }
          volume_mount {
            name       = "cache"
            mount_path = "/app/cache"
          }
          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "1024Mi"
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
          name = "photos"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Photos"
          }
        }

        volume {
          name = "logs"
          empty_dir {}
        }

        volume {
          name = "cache"
          empty_dir {}
        }
      }
    }
  }
}



