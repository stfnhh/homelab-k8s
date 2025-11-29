resource "kubernetes_service" "service" {
  metadata {
    name      = "kopia"
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
