output "rancher_password" {
  value = random_password.password.result
  sensitive = true
}