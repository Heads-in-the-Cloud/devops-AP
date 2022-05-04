config {
    plugin_dir = ".tflint.d/plugins"

    varfile = ["tfvars/input.tfvars"]
}

plugin "aws" {
    enabled = true
    version = "0.13.3"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}