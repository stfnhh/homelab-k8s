resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.name
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}
