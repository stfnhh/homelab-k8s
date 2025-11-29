resource "kubernetes_deployment" "deployment" {
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
          image             = "brandawg93/peanut:5.18.0@sha256:70062870e649b3bcf8c5165353195d3b30e5e4ad0592c2925cee59ec2df327c3"
          image_pull_policy = "Always"

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

            capabilities {
              drop = ["ALL"]
            }
          }

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
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}
