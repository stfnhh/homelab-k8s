resource "kubernetes_namespace" "kopia" {
  metadata {
    name = "kopia"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_persistent_volume_claim" "kopia_config" {
  metadata {
    name      = "kopia-config"
    namespace = kubernetes_namespace.kopia.metadata[0].name
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

resource "kubernetes_deployment" "kopia" {
  metadata {
    name      = "kopia"
    namespace = kubernetes_namespace.kopia.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "kopia" }
    }

    template {
      metadata {
        labels = { app = "kopia" }
      }

      spec {
        security_context {
          fs_group = 1000
        }

        container {
          name              = "kopia"
          image             = "kopia/kopia:0.17.0"
          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }

          args = [
            "server", "start",
            "--address=0.0.0.0:51515",
            "--insecure",
            "--disable-csrf-token-checks",
            "--without-password"
          ]

          port {
            container_port = 51515
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/config"
          }
          volume_mount {
            name       = "photos"
            mount_path = "/photos"
          }
          volume_mount {
            name       = "logs"
            mount_path = "/app/logs"
          }
          volume_mount {
            name       = "cache"
            mount_path = "/app/cache"
          }
          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "1024Mi"
            }
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.kopia_config.metadata[0].name
          }
        }

        volume {
          name = "photos"
          nfs {
            server = var.nfs_server_ip
            path   = "/var/nfs/shared/Photos"
          }
        }

        volume {
          name = "logs"
          empty_dir {}
        }

        volume {
          name = "cache"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "kopia" {
  metadata {
    name      = "kopia"
    namespace = kubernetes_namespace.kopia.metadata[0].name
  }

  spec {
    selector = { app = "kopia" }

    port {
      port        = 51515
      target_port = 51515
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "kopia_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "kopia"
      namespace = kubernetes_namespace.kopia.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`kopia.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.kopia.metadata[0].name
              port = 51515
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
