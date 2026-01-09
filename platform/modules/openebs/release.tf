resource "helm_release" "release" {
  name       = "openebs"
  repository = "https://openebs.github.io/charts"
  chart      = "openebs"
  namespace  = "openebs"

  create_namespace = true

  values = [
    yamlencode({
      localprovisioner = {
        enabled = true
        hostpathClass = {
          enabled           = true
          name              = "openebs-hostpath"
          basePath          = "/mnt/storage"
          reclaimPolicy     = "Retain"
          volumeBindingMode = "WaitForFirstConsumer"
        }
      }

      jiva = {
        enabled = false
      }

      cstor = {
        enabled = false
      }

      ndm = {
        enabled = false
      }

      zfs-localpv = {
        enabled = false
      }
    })
  ]
}
