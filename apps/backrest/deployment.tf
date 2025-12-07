resource "kubernetes_deployment" "backrest" {
  # checkov:skip=CKV_K8S_22: Backrest requires writable root filesystem for restic and temp files.

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
          image             = "garethgeorge/backrest:v1.10.1@sha256:1308397161321b3c5aeca8acc6bf26eccb990df385f2532d3ce0eaa8b483dedf"
          image_pull_policy = "Always"

          port {
            container_port = 9898
          }

          security_context {
            run_as_non_root           = true
            run_as_user               = 1000
            run_as_group              = 1000
            allow_privilege_escalation = false
            privileged                = false
            read_only_root_filesystem = false # Backrest requires write access — already justified.
            capabilities {
              drop = ["ALL"]
            }
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "768Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9898
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 9898
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 2
            failure_threshold     = 3
          }

          env {
            name  = "BACKREST_PORT"
            value = "0.0.0.0:9898"
          }
          env {
            name  = "BACKREST_DATA"
            value = "/data"
          }
          env {
            name  = "BACKREST_CONFIG"
            value = "/config/config.json"
          }
          env {
            name  = "XDG_CACHE_HOME"
            value = "/cache"
          }
          env {
            name  = "TMPDIR"
            value = "/tmp"
          }
          env {
            name  = "TZ"
            value = "America/New_York"
          }

          volume_mount {
            name       = "pvc"
            mount_path = "/config"
            sub_path   = "config"
          }

          volume_mount {
            name       = "pvc"
            mount_path = "/data"
            sub_path   = "data"
          }

          volume_mount {
            name       = "pvc"
            mount_path = "/cache"
            sub_path   = "cache"
          }

          volume_mount {
            name       = "pvc"
            mount_path = "/tmp"
            sub_path   = "tmp"
          }

          volume_mount {
            name       = "photos"
            mount_path = "/userdata/photos"
          }
        }

        volume {
          name = "pvc"
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
      }
    }
  }
}
