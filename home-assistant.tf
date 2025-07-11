# Headless Service to allow manual Endpoints definition
resource "kubernetes_service" "home_assistant_proxy" {
  metadata {
    name      = "home-assistant-proxy"
    namespace = "default"
    annotations = {
      "traefik.ingress.kubernetes.io/service.pass-host-header" = "true"
    }
  }

  spec {
    cluster_ip = "None"

    port {
      name        = "http"
      port        = 8123
      target_port = 8123
      protocol    = "TCP"
    }

    selector = {}
  }
}

# Manual Endpoints object pointing to external Home Assistant IP
resource "kubernetes_endpoints" "home_assistant_proxy" {
  metadata {
    name      = kubernetes_service.home_assistant_proxy.metadata[0].name
    namespace = "default"
  }

  subset {
    address {
      ip = var.home_assistant_ip
    }

    port {
      name = "http"
      port = 8123
    }
  }
}

# IngressRoute to expose Home Assistant through Traefik
resource "kubernetes_manifest" "home_assistant_ingressroute" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "home-assistant"
      namespace = "default"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`ha.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "home-assistant-proxy"
              kind = "Service"
              port = 8123
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
