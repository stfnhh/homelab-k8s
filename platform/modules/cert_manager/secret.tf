resource "kubernetes_secret" "secret" {
  metadata {
    name      = "route53-credentials"
    namespace = "cert-manager"
  }

  data = {
    access-key-id     = aws_iam_access_key.iam_access_key.id
    secret-access-key = aws_iam_access_key.iam_access_key.secret
  }
}
