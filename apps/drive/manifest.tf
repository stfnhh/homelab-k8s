resource "kubernetes_manifest" "manifest_transport" {
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

resource "kubernetes_manifest" "manifest_ingressroute" {
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
              name             = "drive"
              port             = 443
              serversTransport = kubernetes_manifest.manifest_transport.manifest.metadata.name
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
