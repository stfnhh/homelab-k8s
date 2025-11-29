resource "kubernetes_service" "service" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    selector = {
      app = local.name
    }

    port {
      port        = 8096
      target_port = 8096
    }

    type = "ClusterIP"
  }
}
