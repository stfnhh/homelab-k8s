resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "immich"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

