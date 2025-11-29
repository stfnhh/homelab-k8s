resource "kubernetes_service" "service" {
  # checkov:skip=CKV_K8S_21: ignoring default namespace rule

  metadata {
    name      = local.name
    namespace = "default"
  }

  spec {
    type = "ClusterIP"
    port {
      port        = 443
      target_port = 443
      protocol    = "TCP"
    }
  }
}
