variable "domain" {
  description = "Domain"
  type = string
}

variable "email" {
  description = "Email"
  type = string
}

variable "region" {
  description = "AWS Region"
  default = "us-east-1"
  type = string
}

variable "nfs_server_ip" {
  description = "IP of NFS server"
  type = string
}

variable "zone_id" {
  description = "Route53 Zone ID"
  type = string
}