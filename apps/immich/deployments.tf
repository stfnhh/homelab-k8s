resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_22: container requires write access and cannot run read-only

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
          image             = "ghcr.io/immich-app/immich-server:v2.4.1@sha256:ec3b1291a8ab988ae03dab2230dc68fd74aec3df56b2eecd852d42630f38a81c"
          image_pull_policy = "Always"

          security_context {
            run_as_non_root            = true
            run_as_user                = 1000
            run_as_group               = 1000
            allow_privilege_escalation = false

            capabilities {
              drop = ["ALL"]
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3001
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3001
            }
            initial_delay_seconds = 10
            period_seconds        = 20
            timeout_seconds       = 5
            failure_threshold     = 5
          }


          env {
            name  = "REDIS_HOSTNAME"
            value = "redis.redis.svc.cluster.local"
          }
          env {
            name  = "IMMICH_PORT"
            value = "3001"
          }
          env {
            name = "DB_URL"
            value_from {
              secret_key_ref {
                name = "immich-db-url"
                key  = "DB_URL"
              }
            }
          }
          port {
            container_port = 3001
          }
          volume_mount {
            name       = "uploads"
            mount_path = "/usr/src/app/upload"
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }
        }
        volume {
          name = "uploads"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Photos"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "immich_machine_learning" {
  # checkov:skip=CKV_K8S_22:immich ml container requires write access and cannot run read-only


  metadata {
    name      = "${local.name}-machine-learning"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${local.name}-machine-learning"
      }
    }
    template {
      metadata {
        labels = {
          app = "${local.name}-machine-learning"
        }
      }
      spec {
        container {
          name              = "${local.name}-machine-learning"
          image             = "ghcr.io/immich-app/immich-machine-learning:v2.4.1@sha256:ea0568e8d8898291c32946e48dc68cb4d092d38531c021d359aa3a5eb30a18d9"
          image_pull_policy = "Always"

          security_context {
            run_as_non_root            = true
            run_as_user                = 1000
            run_as_group               = 1000
            allow_privilege_escalation = false

            capabilities {
              drop = ["ALL"]
            }
          }

          volume_mount {
            name       = "dotcache"
            mount_path = "/.cache"
          }
          volume_mount {
            name       = "cache"
            mount_path = "/cache"
          }
          volume_mount {
            name       = "config"
            mount_path = "/.config"
          }


          readiness_probe {
            http_get {
              path = "/"
              port = 3003
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3003
            }
            initial_delay_seconds = 10
            period_seconds        = 20
          }

          env {
            name  = "IMMICH_PORT"
            value = "3003"
          }

          port {
            container_port = 3003
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "2000m"
              memory = "4Gi"
            }
          }
        }
        volume {
          name = "dotcache"
          empty_dir {}
        }
        volume {
          name = "cache"
          empty_dir {}
        }
        volume {
          name = "config"
          empty_dir {}
        }
      }
    }
  }
}

