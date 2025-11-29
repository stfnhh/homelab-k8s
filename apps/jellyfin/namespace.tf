resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "jellyfin"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
