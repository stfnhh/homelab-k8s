resource "kubernetes_secret" "secret" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  type                           = "Opaque"
  wait_for_service_account_token = true

  data = {
    API_KEY          = ""
    WEBHOOK_URL      = ""
    LATITUDE         = ""
    LONGITUDE        = ""
    DISTANCE         = ""
    ALERT_CATEGORIES = ""
    POLL_INTERVAL    = ""
    BLACKLIST_TTL    = ""
    QUIET_START      = ""
    QUIET_END        = ""
  }

  lifecycle {
    ignore_changes = [
      data
    ]
  }
}

