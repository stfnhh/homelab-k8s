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
