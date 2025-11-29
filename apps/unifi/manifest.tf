resource "kubernetes_manifest" "manifest_transport" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "unifi-transport"
      namespace = "default"
    }
    spec = {
      serverName         = "unifi.${var.domain}"
      insecureSkipVerify = true
    }
  }
}

resource "kubernetes_manifest" "manifest_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "unifi"
      namespace = "default"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`unifi.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name             = "unifi"
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
