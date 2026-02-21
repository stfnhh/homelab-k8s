# tflint-ignore: terraform_unused_declarations
data "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = "postgres"
  }
}

# tflint-ignore: terraform_unused_declarations
data "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = "redis"
  }
}
