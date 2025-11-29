resource "kubernetes_service" "service" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
