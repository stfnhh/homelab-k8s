resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "peanut"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
