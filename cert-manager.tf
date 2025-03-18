resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.0"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  timeout = 300
  wait    = true
}


resource "kubernetes_secret" "route53_credentials" {
  metadata {
    name      = "route53-credentials"
    namespace = "cert-manager"
  }

  data = {
    access-key-id     = aws_iam_access_key.iam_access_key.id
    secret-access-key = aws_iam_access_key.iam_access_key.secret
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
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
}

resource "kubernetes_manifest" "wildcard_certificate" {
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
}
