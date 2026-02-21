resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_22: container requires write access and cannot run read-only
  # checkov:skip=CKV_K8S_28: NET_RAW is required

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
          fs_group            = 1000
          supplemental_groups = [993, 44]
        }

        container {
          name              = local.name
          image             = "jellyfin/jellyfin:10.11@sha256:1edf3f17997acbe139718f252a7d2ded2706762390d787a34204668498dbc5f6"
          image_pull_policy = "Always"

          security_context {
            run_as_user                = 1000
            run_as_group               = 1000
            allow_privilege_escalation = false

            capabilities {
              drop = ["ALL"]
            }
          }

          port {
            container_port = 8096
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8096
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8096
            }
            initial_delay_seconds = 15
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          # Media mounts
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "movies"
            mount_path = "/data/movies"
          }

          volume_mount {
            name       = "music"
            mount_path = "/data/music"
          }

          volume_mount {
            name       = "tv"
            mount_path = "/data/tv"
          }

          volume_mount {
            name       = "dri"
            mount_path = "/dev/dri"
          }

          resources {
            requests = {
              cpu    = "1000m"
              memory = "2048Mi"
            }
            limits = {
              cpu    = "2000m"
              memory = "3072Mi"
            }
          }
        }

        # PVC
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = local.name
          }
        }

        # Media
        volume {
          name = "movies"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Media/movies"
          }
        }

        volume {
          name = "music"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Media/music"
          }
        }

        volume {
          name = "tv"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Media/tv"
          }
        }

        # 🔥 Host GPU device
        volume {
          name = "dri"
          host_path {
            path = "/dev/dri"
            type = "Directory"
          }
        }
      }
    }
  }
}
