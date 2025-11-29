resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "ariang"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}