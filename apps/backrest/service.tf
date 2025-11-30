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
      port        = 9898
      target_port = 9898
    }
  }
}
