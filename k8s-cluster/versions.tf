terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.52.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.92.0"
    }
  }
}
