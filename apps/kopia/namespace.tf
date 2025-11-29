resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "kopia"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}