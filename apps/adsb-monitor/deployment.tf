resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_35:Using env vars intentionally

  wait_for_rollout = true
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
          image             = "ghcr.io/stfnhh/adsb-alarm:v0.2.3@sha256:421303de34eed1bd3ba6f41a942a32680a1613de7d33b8921cd403e0f193ab89"
          image_pull_policy = "Always"

          security_context {
            run_as_non_root           = true
            run_as_user               = 1000
            read_only_root_filesystem = true

            capabilities {
              drop = ["ALL"]
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.secret.metadata[0].name
            }
          }

          readiness_probe {
            tcp_socket {
              port = 8081
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            tcp_socket {
              port = 8081
            }
            initial_delay_seconds = 5
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "20m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }

        restart_policy = "Always"
      }
    }
  }
}
