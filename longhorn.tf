resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
  }

  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = kubernetes_namespace.longhorn.metadata[0].name
  version    = "1.8.0"

  set {
    name  = "defaultSettings.defaultDataPath"
    value = "/mnt/storage"
  }

  lifecycle {
    ignore_changes = [
      id
    ]
  }

}
