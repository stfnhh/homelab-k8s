resource "kubernetes_namespace" "tidarr" {
  metadata {
    name = "tidarr"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_persistent_volume_claim" "tidarr_config" {
  metadata {
    name      = "tidarr-config"
    namespace = kubernetes_namespace.tidarr.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_persistent_volume_claim" "tidarr_mongo" {
  metadata {
    name      = "tidarr-mongo"
    namespace = kubernetes_namespace.tidarr.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_deployment" "tidarr" {
  metadata {
    name      = "tidarr"
    namespace = kubernetes_namespace.tidarr.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "tidarr" }
    }

    template {
      metadata {
        labels = { app = "tidarr" }
      }

      spec {
        container {
          name  = "tidarr"
          image = "cstaelen/tidarr:latest"
          port {
            container_port = 8484
          }

          env {
            name  = "TIDARR_MONGO_URL"
            value = "mongodb://tidarr-mongo:27017/tidarr"
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/home/app/standalone/library"
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "1024Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1536Mi"
            }
          }
        }

        container {
          name  = "mongo"
          image = "mongo:latest"
          port {
            container_port = 27017
          }

          volume_mount {
            name       = "mongo-data"
            mount_path = "/data/db"
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.tidarr_config.metadata[0].name
          }
        }

        volume {
          name = "mongo-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.tidarr_mongo.metadata[0].name
          }
        }

        volume {
          name = "downloads"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Media/music"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "tidarr" {
  metadata {
    name      = "tidarr"
    namespace = kubernetes_namespace.tidarr.metadata[0].name
  }

  spec {
    selector = { app = "tidarr" }
    port {
      port        = 8484
      target_port = 8484
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "tidarr_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "tidarr"
      namespace = kubernetes_namespace.tidarr.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`tidarr.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.tidarr.metadata[0].name
              port = 8484
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
