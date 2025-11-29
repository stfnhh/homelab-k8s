resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "adsb-monitor"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}