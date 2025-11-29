resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_20: container requires privileged escalation behavior
  # checkov:skip=CKV_K8S_22: image requires RW filesystem
  # checkov:skip=CKV_K8S_23: image requires root privileges
  # checkov:skip=CKV_K8S_28: NET_RAW is required for this image

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
          name              = local.name
          image             = "hurlenko/aria2-ariang:1.3.11@sha256:cee118a74e27539f4e57647f046a4cbe4b999ff17d7d15672a7f7bd60f2ab6ee"
          image_pull_policy = "Always"

          security_context {
            run_as_user                = 0
            run_as_group               = 0
            allow_privilege_escalation = true
            read_only_root_filesystem  = false
            privileged                 = false
          }

          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          env {
            name  = "ARIA2RPCPORT"
            value = "443"
          }

          port {
            container_port = 8080
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 15
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          volume_mount {
            name       = "config"
            mount_path = "/aria2/conf"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/aria2/data"
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
          name = "downloads"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Media/downloads"
          }
        }
      }
    }
  }
}




