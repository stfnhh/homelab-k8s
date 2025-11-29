resource "kubernetes_service" "service" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    selector = {
      app = "immich"
    }
    port {
      port        = 3001
      target_port = 3001
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "service_machine_learning" {
  metadata {
    name      = "${local.name}-machine-learning"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "${local.name}-machine-learning"
    }
    port {
      port        = 3003
      target_port = 3003
    }
    type = "ClusterIP"
  }
}