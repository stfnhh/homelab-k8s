resource "kubernetes_secret" "immich_db_url" {
  metadata {
    name      = "immich-db-url"
    namespace = kubernetes_namespace.immich.metadata[0].name
  }

  data = {
    DB_URL = "postgresql://postgres:${random_password.postgres_password.result}@postgres.postgres.svc.cluster.local:5432/immich"
  }
}

# resource "kubernetes_job" "immich_db_bootstrap" {
#   metadata {
#     name      = "immich-db-bootstrap"
#     namespace = kubernetes_namespace.immich.metadata[0].name
#     labels = {
#       app = "immich-db-bootstrap"
#     }
#   }

#   spec {
#     backoff_limit              = 1
#     ttl_seconds_after_finished = 300 # auto-clean after 5 minutes

#     template {
#       metadata {
#         labels = {
#           app = "immich-db-bootstrap"
#         }
#       }
#       spec {
#         restart_policy = "OnFailure"

#         container {
#           name  = "create-immich-db"
#           image = "pgvector/pgvector:pg18-trixie"

#           env {
#             name = "DB_URL"
#             value_from {
#               secret_key_ref {
#                 name = "immich-db-url"
#                 key  = "DB_URL"
#               }
#             }
#           }

#           command = [
#             "sh", "-c",
#             <<-EOT
#               # replace /immich with /postgres for bootstrap connection
#               BOOTSTRAP_URL=$(echo "$DB_URL" | sed 's|/immich$|/postgres|')

#               psql "$BOOTSTRAP_URL" -tc "SELECT 1 FROM pg_database WHERE datname='immich'" | grep -q 1 \
#                 || psql "$BOOTSTRAP_URL" -c "CREATE DATABASE immich;"
#             EOT
#           ]
#         }
#       }
#     }
#   }
# }

resource "kubernetes_namespace" "immich" {
  metadata {
    name = "immich"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_deployment" "immich" {
  metadata {
    name      = "immich"
    namespace = kubernetes_namespace.immich.metadata[0].name
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
          image             = "ghcr.io/immich-app/immich-server:release"
          image_pull_policy = "Always"
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

resource "kubernetes_service" "immich" {
  metadata {
    name      = "immich"
    namespace = kubernetes_namespace.immich.metadata[0].name
  }
  spec {
    selector = {
      app = "immich"
    }
    port {
      port        = 3001
      target_port = 3001
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "immich_machine_learning" {
  metadata {
    name      = "immich-machine-learning"
    namespace = kubernetes_namespace.immich.metadata[0].name
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
          image             = "ghcr.io/immich-app/immich-machine-learning:v1.143.1"
          image_pull_policy = "Always"
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

resource "kubernetes_service" "immich_machine_learning" {
  metadata {
    name      = "immich-machine-learning"
    namespace = kubernetes_namespace.immich.metadata[0].name
  }

  spec {
    selector = {
      app = "immich-machine-learning"
    }
    port {
      port        = 3003
      target_port = 3003
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "immich_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "immich"
      namespace = kubernetes_namespace.immich.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`immich.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.immich.metadata[0].name
              port = 3001
            }
          ]
        }
      ]
      tls = {
        secretName = "wildcard-${replace(var.domain, ".", "-")}-tls"
      }
    }
  }
}
