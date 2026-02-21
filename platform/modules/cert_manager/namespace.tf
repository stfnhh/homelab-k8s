resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "cert-manager"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}