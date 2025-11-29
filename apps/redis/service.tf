resource "kubernetes_service" "service" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "redis"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}
