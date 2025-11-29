resource "kubernetes_service" "service" {
  metadata {
    name      = "peanut"
    namespace = kubernetes_namespace.namespace.metadata[0].name
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