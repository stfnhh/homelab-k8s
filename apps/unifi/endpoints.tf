resource "kubernetes_endpoints" "endpoints" {
  metadata {
    name      = "unifi"
    namespace = "default"
  }

  subset {
    address {
      ip = var.nfs_server_ip
    }

    port {
      port     = 443
      protocol = "TCP"
    }
  }
}

