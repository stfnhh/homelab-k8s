resource "kubernetes_manifest" "rancher_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "rancher-${replace(var.domain, ".", "-")}"
      namespace = "cattle-system" # Use cattle-system for Rancher
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

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  namespace  = "cattle-system"
  version    = "2.10.2"

  set {
    name  = "hostname"
    value = "rancher.${var.domain}"
  }

  set {
    name  = "ingress.tls.source"
    value = "secret"
  }

  set {
    name  = "ingress.tls.secretName"
    value = "rancher-${replace(var.domain, ".", "-")}-tls"
  }

  set {
    name  = "bootstrapPassword"
    value = random_password.password.result
  }
}
