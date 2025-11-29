resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "filebrowser"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
