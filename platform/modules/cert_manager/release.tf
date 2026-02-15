resource "helm_release" "release" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.0"
  namespace        = "cert-manager"
  create_namespace = true

  set = [{
    name  = "installCRDs"
    value = "true"
  }]

  timeout = 300
  wait    = true

  depends_on = [
    kubernetes_secret.secret
  ]
}