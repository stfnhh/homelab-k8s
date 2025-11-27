resource "kubernetes_manifest" "drive_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "drive"
      namespace = "default"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`drive.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name             = "drive-svc"
              port             = 443
              serversTransport = "drive-transport"
            }
          ]
        }
      ]
      tls = {
        secretName = "wildcard-${replace(var.domain, ".", "-")}-tls"
      }
    }
  }
}

resource "kubernetes_endpoints" "drive_endpoints" {
  metadata {
    name      = "drive-svc"
    namespace = "default"
  }

  subset {
    address {
      ip = "10.0.0.177" # UDM Pro IP
    }

    port {
      port     = 443
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service" "drive_service" {
  metadata {
    name      = "drive-svc"
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

resource "kubernetes_manifest" "drive_transport" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "drive-transport"
      namespace = "default"
    }
    spec = {
      serverName         = "drive.${var.domain}"
      insecureSkipVerify = true
    }
  }
}
