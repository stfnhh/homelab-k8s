resource "helm_release" "release" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = kubernetes_namespace.namespace.metadata[0].name
  version    = "1.8.0"

  set = [{
    name  = "defaultSettings.defaultDataPath"
    value = "/mnt/storage"
  }]

  # lifecycle {
  #   ignore_changes = [
  #     id
  #   ]
  # }
}
