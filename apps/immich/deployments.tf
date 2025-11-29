resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_22: container requires write access and cannot run read-only

  metadata {
    name      = "immich"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  # depends_on = [kubernetes_job.immich_db_bootstrap]
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "immich"
      }
    }
    template {
      metadata {
        labels = {
          app = "immich"
        }
      }
      spec {
        container {
          name              = "immich"
          image             = "ghcr.io/immich-app/immich-server:v2.3.1@sha256:61e9fba6d36d23915dfcb1387ef74db87d1fbf4a924981ced0ce5feb0f71100a"
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
    name      = "immich-machine-learning"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "immich-machine-learning"
      }
    }
    template {
      metadata {
        labels = {
          app = "immich-machine-learning"
        }
      }
      spec {
        container {
          name              = "immich-machine-learning"
          image             = "ghcr.io/immich-app/immich-machine-learning:v2.3.0@sha256:dee0ffce7efba1fabe3efdc23e2e83f89b84d76ad0565072c1cf4055dcf76dd0"
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
      }
    }
  }
}

