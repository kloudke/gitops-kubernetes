terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
