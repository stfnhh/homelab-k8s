resource "kubernetes_namespace" "photoprism" {
  metadata {
    name = "photoprism"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_persistent_volume_claim" "photoprism_storage" {
  metadata {
    name      = "photoprism-storage"
    namespace = kubernetes_namespace.photoprism.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "512Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_persistent_volume_claim" "photoprism_database" {
  metadata {
    name      = "photoprism-database"
    namespace = kubernetes_namespace.photoprism.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "24Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_persistent_volume_claim" "photoprism_originals" {
  metadata {
    name      = "photoprism-originals"
    namespace = kubernetes_namespace.photoprism.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "512Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}

resource "kubernetes_deployment" "photoprism" {
  metadata {
    name      = "photoprism"
    namespace = kubernetes_namespace.photoprism.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "photoprism"
      }
    }
    template {
      metadata {
        labels = {
          app = "photoprism"
        }
      }
      spec {
        security_context {
          fs_group = 1000
        }
        container {
          name              = "photoprism"
          image             = "photoprism/photoprism:latest"
          image_pull_policy = "Always"

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }
          port {
            container_port = 2342
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 2342
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }
          env {
            name = "PHOTOPRISM_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.photoprism_secrets.metadata[0].name
                key  = "admin_password"
              }
            }
          }
          env {
            name  = "PHOTOPRISM_SITE_URL"
            value = "https://photoprism.${var.domain}"
          }
          env {
            name  = "PHOTOPRISM_ORIGINALS_LIMIT"
            value = "5000"
          }
          env {
            name  = "PHOTOPRISM_STORAGE_PATH"
            value = "/photoprism/storage"
          }
          env {
            name  = "PHOTOPRISM_ORIGINALS_PATH"
            value = "/photoprism/originals"
          }
          env {
            name  = "PHOTOPRISM_IMPORT_PATH"
            value = "/photoprism/import"
          }
          volume_mount {
            name       = "storage"
            mount_path = "/photoprism/storage"
          }
          volume_mount {
            name       = "originals"
            mount_path = "/photoprism/originals"
          }
          volume_mount {
            name       = "database"
            mount_path = "/photoprism/database"
          }
          resources {
            requests = {
              cpu    = "1000m"
              memory = "2048Mi"
            }
            limits = {
              cpu    = "2000m"
              memory = "4096Mi"
            }
          }
        }
        volume {
          name = "storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.photoprism_storage.metadata[0].name
          }
        }
        volume {
          name = "originals"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.photoprism_originals.metadata[0].name
          }
        }
        volume {
          name = "database"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.photoprism_database.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "photoprism" {
  metadata {
    name      = "photoprism"
    namespace = kubernetes_namespace.photoprism.metadata[0].name
  }

  spec {
    selector = {
      app = "photoprism"
    }
    port {
      port        = 2342
      target_port = 2342
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "photoprism_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "photoprism"
      namespace = kubernetes_namespace.photoprism.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`photos.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.photoprism.metadata[0].name
              port = 2342
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

resource "kubernetes_secret" "photoprism_secrets" {
  metadata {
    name      = "photoprism-secrets"
    namespace = kubernetes_namespace.photoprism.metadata[0].name
  }
  data = {
    admin_password = random_password.password.result
  }
}
