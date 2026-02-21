tflint {
  required_version = "~> 0.60"
}

config {
  format              = "compact"
  force               = false
  disabled_by_default = false

  ignore_module = {
  }

  varfile = ["terraform.tfvars"]
}

plugin "terraform" {
  enabled = true
  preset  = "all"
}

plugin "aws" {
  enabled = true
  version = "0.44.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
