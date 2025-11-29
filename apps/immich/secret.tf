data "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "postgres-credentials"
    namespace = "postgres"
  }
}

locals {
  pg_user = data.kubernetes_secret.postgres_credentials.data["username"]
  pg_pass = data.kubernetes_secret.postgres_credentials.data["password"]

  db_url = "postgresql://${local.pg_user}:${local.pg_pass}@postgres.postgres.svc.cluster.local:5432/immich"
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "immich-db-url"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    DB_URL = local.db_url
  }
}
