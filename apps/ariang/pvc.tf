resource "kubernetes_persistent_volume_claim" "persistent_volume_claim" {
  metadata {
    name      = "aria2-config"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "longhorn"
  }
}
