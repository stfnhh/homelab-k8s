resource "kubernetes_manifest" "unifi_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
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
              name = "unifi-svc"
              port = 443
              serversTransport = "unifi-transport"
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

resource "kubernetes_endpoints" "unifi_endpoints" {
  metadata {
    name      = "unifi-svc"
    namespace = "default"
  }

  subset {
    address {
      ip = "10.0.0.1" # UDM Pro IP
    }

    port {
      port     = 443
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service" "unifi_service" {
  metadata {
    name      = "unifi-svc"
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

resource "kubernetes_manifest" "unifi_transport" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "unifi-transport"
      namespace = "default"
    }
    spec = {
      serverName          = "unifi.${var.domain}"
      insecureSkipVerify  = true
    }
  }
}
