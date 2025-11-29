resource "kubernetes_persistent_volume_claim" "persistent_volume_claim" {
  metadata {
    name      = "kopia-config"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}
