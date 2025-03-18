resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = "jellyfin"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_config" {
  metadata {
    name      = "jellyfin-config"
    namespace = kubernetes_namespace.jellyfin.metadata[0].name
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

resource "kubernetes_deployment" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jellyfin"
      }
    }
    template {
      metadata {
        labels = {
          app = "jellyfin"
        }
      }
      spec {
        security_context {
          fs_group = 1000
        }
        container {
          name  = "jellyfin"
          image = "jellyfin/jellyfin:latest"
          image_pull_policy = "Always"

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
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

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "movies"
            mount_path = "/data/movies"
          }
          volume_mount {
            name       = "tv"
            mount_path = "/data/tv"
          }
          resources {
            requests = {
              cpu    = "1000m"
              memory = "2048Mi"
            }
            limits = {
              cpu    = "1512m"
              memory = "2560Mi"
            }
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_config.metadata[0].name
          }
        }
        volume {
          name = "movies"
          nfs {
            server = var.nfs_server_ip
            path   = "/media/media/movies"
          }
        }
        volume {
          name = "tv"
          nfs {
            server = var.nfs_server_ip
            path   = "/media/media/tv"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata[0].name
  }

  spec {
    selector = {
      app = "jellyfin"
    }

    port {
      port        = 8096
      target_port = 8096
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "jellyfin_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "jellyfin"
      namespace = kubernetes_namespace.jellyfin.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`jellyfin.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.jellyfin.metadata[0].name
              port = 8096
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
