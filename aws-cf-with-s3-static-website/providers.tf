provider "aws" {
  region = var.region_code_execution

  default_tags {
    tags = {
      Environment      = var.env_name_long
      EnvironmentShort = var.env_name_short
      Project          = var.project_name
      Owner            = var.owner
      TerraformCreated = true
    }
  }
}

provider "aws" {
  alias = "acm"

  region = var.region_code_execution
}

provider "aws" {
  alias = "route53"

  region = var.region_code_execution
}

provider "random" {}
