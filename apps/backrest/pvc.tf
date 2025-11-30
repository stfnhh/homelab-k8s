resource "kubernetes_persistent_volume_claim" "persistent_volume_claim" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}
