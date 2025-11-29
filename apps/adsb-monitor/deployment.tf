resource "kubernetes_deployment" "deployment" {
  # checkov:skip=CKV_K8S_35:Using env vars intentionally

  wait_for_rollout = true
  metadata {
    name      = "adsb-monitor"
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
          image             = "ghcr.io/stfnhh/adsb-alarm:v0.2.1@sha256:978c4b73ebfc508570194ef9394ff7bfdef1068229f70148a50e936fe775854c"
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
