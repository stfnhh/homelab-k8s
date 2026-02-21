resource "kubernetes_endpoints" "endpoints" {
  metadata {
    name      = local.name
    namespace = "default"
  }

  subset {
    address {
      ip = var.server_ip
    }

    port {
      port     = 443
      protocol = "TCP"
    }
  }
}

