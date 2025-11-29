resource "random_password" "password" {
  length  = 24
  special = false
}

resource "helm_release" "release" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  namespace  = "cattle-system"
  version    = "2.13.0"

  set = [
    {
      name  = "hostname"
      value = "rancher.${var.domain}"
    },
    {
      name  = "ingress.tls.source"
      value = "secret"
    },
    {
      name  = "ingress.tls.secretName"
      value = "rancher-${replace(var.domain, ".", "-")}-tls"
    },
    {
      name  = "bootstrapPassword"
      value = random_password.password.result
    }
  ]
}

