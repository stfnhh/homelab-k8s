resource "kubernetes_namespace" "peanut" {
  metadata {
    name = "peanut"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_deployment" "peanut" {
  metadata {
    name      = "peanut"
    namespace = kubernetes_namespace.peanut.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "peanut"
      }
    }

    template {
      metadata {
        labels = {
          app = "peanut"
        }
      }

      spec {
        container {
          name              = "peanut"
          image             = "brandawg93/peanut:latest"
          image_pull_policy = "Always"

          env {
            name  = "NUT_HOST"
            value = "nut.nut.svc.cluster.local" # points to your NUT server service
          }
          env {
            name  = "NUT_PORT"
            value = "3493"
          }
          env {
            name  = "NUT_USERNAME"
            value = "monuser"
          }
          env {
            name  = "NUT_PASSWORD"
            value = "secret"
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
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
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
      }
    }
  }
}

resource "kubernetes_service" "peanut" {
  metadata {
    name      = "peanut"
    namespace = kubernetes_namespace.peanut.metadata[0].name
  }

  spec {
    selector = {
      app = "peanut"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "peanut_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "peanut"
      namespace = kubernetes_namespace.peanut.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`peanut.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.peanut.metadata[0].name
              port = 8080
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
