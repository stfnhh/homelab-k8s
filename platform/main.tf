module "cert_manager" {
  source = "./modules/cert_manager"

  domain  = var.domain
  zone_id = var.zone_id
  email   = var.email
  region  = var.region

  providers = {
    aws        = aws
    kubernetes = kubernetes
  }
}

module "traefik" {
  source = "./modules/traefik"

  domain = var.domain

  providers = {
    kubernetes = kubernetes
  }
}
