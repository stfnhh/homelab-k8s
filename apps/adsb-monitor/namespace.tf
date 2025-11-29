resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.name
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}