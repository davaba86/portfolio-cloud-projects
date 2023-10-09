provider "acme" {
  server_url = "https://${local.acme_url_portion}.api.letsencrypt.org/directory"
}

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

provider "http" {

}

provider "local" {

}

provider "tls" {

}
