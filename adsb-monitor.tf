resource "kubernetes_namespace" "adsb" {
  metadata {
    name = "adsb-monitor"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "adsb_secret" {
  metadata {
    name      = "adsb-monitor"
    namespace = kubernetes_namespace.adsb.metadata[0].name
  }

  type = "Opaque"

  data = {
    API_KEY          = ""
    WEBHOOK_URL      = ""
    LATITUDE         = ""
    LONGITUDE        = ""
    DISTANCE         = ""
    ALERT_CATEGORIES = ""
    POLL_INTERVAL    = ""
    BLACKLIST_TTL    = ""
    QUIET_START      = ""
    QUIET_END        = ""
  }

  lifecycle {
    ignore_changes = [
      data
    ]
  }
}

resource "kubernetes_deployment" "adsb" {
  metadata {
    name      = "adsb-monitor"
    namespace = kubernetes_namespace.adsb.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "adsb-monitor"
      }
    }

    template {
      metadata {
        labels = {
          app = "adsb-monitor"
        }
      }

      spec {
        container {
          name              = "adsb-monitor"
          image             = "ghcr.io/stfnhh/adsb-alarm:v0.2.0@sha256:3b95cc488048dacb868bf513dfcae685b5f6e3a1008c4a4fbb688c0e385097eb"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = kubernetes_secret.adsb_secret.metadata[0].name
            }
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
            requests = {
              cpu    = "20m"
              memory = "32Mi"
            }
          }
        }

        restart_policy = "Always"
      }
    }
  }
}
