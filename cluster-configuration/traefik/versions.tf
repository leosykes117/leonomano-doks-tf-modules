terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
  }
}
