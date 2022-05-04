config {
    plugin_dir = ".tflint.d/plugins"
}

plugin "aws" {
    enabled = true
    version = "0.13.3"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}