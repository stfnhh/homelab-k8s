resource "kubernetes_manifest" "manifest_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region = var.region
                accessKeyIDSecretRef = {
                  name = "route53-credentials"
                  key  = "access-key-id"
                }
                secretAccessKeySecretRef = {
                  name = "route53-credentials"
                  key  = "secret-access-key"
                }
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [helm_release.release]
}

resource "kubernetes_manifest" "manifest_wildcard_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-${replace(var.domain, ".", "-")}"
      namespace = "default"
    }
    spec = {
      secretName = "wildcard-${replace(var.domain, ".", "-")}-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.${var.domain}"
      ]
    }
  }
  depends_on = [helm_release.release]

}
