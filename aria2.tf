resource "kubernetes_namespace" "ariang" {
  metadata {
    name = "ariang"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_persistent_volume_claim" "aria2_config" {
  metadata {
    name      = "aria2-config"
    namespace = kubernetes_namespace.ariang.metadata[0].name
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

resource "kubernetes_deployment" "ariang" {
  metadata {
    name      = "ariang"
    namespace = kubernetes_namespace.ariang.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ariang"
      }
    }

    template {
      metadata {
        labels = {
          app = "ariang"
        }
      }

      spec {
        container {
          name  = "ariang"
          image = "hurlenko/aria2-ariang"
          image_pull_policy = "always"

          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          env {
            name  = "ARIA2RPCPORT"
            value = "443"
          }

          port {
            container_port = 8080
          }

          volume_mount {
            name       = "config"
            mount_path = "/aria2/conf"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/aria2/data"
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.aria2_config.metadata[0].name
          }
        }

        volume {
          name = "downloads"
          nfs {
            server = var.nfs_server_ip
            path   = "/media/media/downloads"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ariang" {
  metadata {
    name      = "ariang"
    namespace = kubernetes_namespace.ariang.metadata[0].name
  }

  spec {
    selector = {
      app = "ariang"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "ariang_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "ariang"
      namespace = kubernetes_namespace.ariang.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`ariang.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.ariang.metadata[0].name
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
