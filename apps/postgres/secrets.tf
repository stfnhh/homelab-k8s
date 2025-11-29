resource "random_password" "password" {
  length  = 20
  special = false
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    username = "postgres"
    password = random_password.password.result
  }
}
