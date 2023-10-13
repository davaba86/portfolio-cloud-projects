terraform {
  required_version = "~> 1.5.7"

  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.18.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
