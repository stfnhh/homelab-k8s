resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "filegator"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
