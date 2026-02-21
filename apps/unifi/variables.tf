variable "server_ip" {
  type        = string
  description = "IPv4 address of the server"

  validation {
    condition     = can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.server_ip))
    error_message = "server_ip must be a valid IPv4 address."
  }
}

variable "domain" {
  type        = string
  description = "DNS domain name"

  validation {
    condition = can(
      regex(
        "^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)+$",
        var.domain
      )
    )
    error_message = "domain must be a valid DNS domain (e.g., example.com)."
  }
}
