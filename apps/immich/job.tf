

# resource "kubernetes_job" "immich_db_bootstrap" {
#   metadata {
#     name      = "immich-db-bootstrap"
#     namespace = kubernetes_namespace.namespace.metadata[0].name
#     labels = {
#       app = "immich-db-bootstrap"
#     }
#   }

#   spec {
#     backoff_limit              = 1
#     ttl_seconds_after_finished = 300 # auto-clean after 5 minutes

#     template {
#       metadata {
#         labels = {
#           app = "immich-db-bootstrap"
#         }
#       }
#       spec {
#         restart_policy = "OnFailure"

#         container {
#           name  = "create-immich-db"
#           image = "pgvector/pgvector:pg18-trixie"

#           env {
#             name = "DB_URL"
#             value_from {
#               secret_key_ref {
#                 name = "immich-db-url"
#                 key  = "DB_URL"
#               }
#             }
#           }

#           command = [
#             "sh", "-c",
#             <<-EOT
#               # replace /immich with /postgres for bootstrap connection
#               BOOTSTRAP_URL=$(echo "$DB_URL" | sed 's|/immich$|/postgres|')

#               psql "$BOOTSTRAP_URL" -tc "SELECT 1 FROM pg_database WHERE datname='immich'" | grep -q 1 \
#                 || psql "$BOOTSTRAP_URL" -c "CREATE DATABASE immich;"
#             EOT
#           ]
#         }
#       }
#     }
#   }
# }
