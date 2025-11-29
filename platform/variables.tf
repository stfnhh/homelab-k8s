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

variable "zone_id" {
  type        = string
  description = "Route53 hosted zone ID (starts with 'Z')."

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.zone_id))
    error_message = "Route53 zone_id must start with 'Z' and contain only A–Z and 0–9 characters (e.g., Z123ABC456)."
  }
}

variable "email" {
  type        = string
  description = "Contact email address."

  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.email))
    error_message = "Email must be a valid address such as 'user@example.com'."
  }
}

variable "region" {
  type        = string
  description = "AWS region to deploy into."

  # Define allowed AWS regions
  validation {
    condition = contains([
      "us-east-1",
      "us-east-2",
      "us-west-1",
      "us-west-2",
      "af-south-1",
      "ap-east-1",
      "ap-south-1",
      "ap-south-2",
      "ap-southeast-1",
      "ap-southeast-2",
      "ap-southeast-3",
      "ap-northeast-1",
      "ap-northeast-2",
      "ap-northeast-3",
      "ca-central-1",
      "eu-central-1",
      "eu-central-2",
      "eu-west-1",
      "eu-west-2",
      "eu-west-3",
      "eu-north-1",
      "eu-south-1",
      "eu-south-2",
      "me-central-1",
      "me-south-1",
      "sa-east-1"
    ], var.region)
    error_message = "Region must be a valid AWS region string."
  }
}
