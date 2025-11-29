resource "kubernetes_manifest" "manifest_transport" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "unifi-transport"
      namespace = "default"
    }
    spec = {
      serverName         = "${local.name}.${var.domain}"
      insecureSkipVerify = true
    }
  }
}

resource "kubernetes_manifest" "manifest_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = local.name
      namespace = "default"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`${local.name}.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name             = local.name
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
