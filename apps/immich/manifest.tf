resource "kubernetes_manifest" "manifest" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "immich"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`immich.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.service.metadata[0].name
              port = 3001
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
