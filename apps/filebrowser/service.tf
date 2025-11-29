resource "kubernetes_service" "service" {
  metadata {
    name      = "filebrowser"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "filebrowser"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}