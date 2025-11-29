resource "kubernetes_service" "service" {
  metadata {
    name      = "filegator"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "filegator"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}