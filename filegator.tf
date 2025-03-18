resource "kubernetes_namespace" "filegator" {
  metadata {
    name = "filegator"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_persistent_volume_claim" "filegator_config" {
  metadata {
    name      = "filegator-config"
    namespace = kubernetes_namespace.filegator.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_deployment" "filegator" {
  metadata {
    name      = "filegator"
    namespace = kubernetes_namespace.filegator.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "filegator"
      }
    }

    template {
      metadata {
        labels = {
          app = "filegator"
        }
      }

      spec {
        container {
          name  = "filegator"
          image = "maxime1907/filegator"
          image_pull_policy = "Always"

          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          env {
            name  = "TZ"
            value = "America/New_York"
          }

          port {
            container_port = 80
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

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.filegator_config.metadata[0].name
          }
        }

        volume {
          name = "data"
          nfs {
            server = var.nfs_server_ip
            path   = "/media/media"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "filegator" {
  metadata {
    name      = "filegator"
    namespace = kubernetes_namespace.filegator.metadata[0].name
  }

  spec {
    selector = {
      app = "filegator"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "filegator_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "filegator"
      namespace = kubernetes_namespace.filegator.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`files.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.filegator.metadata[0].name
              port = 80
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
