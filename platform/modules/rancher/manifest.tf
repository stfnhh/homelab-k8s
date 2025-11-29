resource "kubernetes_manifest" "manifest" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "rancher-${replace(var.domain, ".", "-")}"
      namespace = "cattle-system"
    }
    spec = {
      secretName = "rancher-${replace(var.domain, ".", "-")}-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "rancher.${var.domain}"
      ]
    }
  }
}
