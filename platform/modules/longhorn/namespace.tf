resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "longhorn-system"
  }

  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
}
