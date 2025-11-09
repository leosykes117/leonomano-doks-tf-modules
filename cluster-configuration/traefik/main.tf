terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
  }
}

variable "traefik_values" {
  description = "Map of values that will be merged with the default values"
  type        = map(any)
  default     = {}
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

locals {
  default_traekif_values = {
    service = {
      type = "LoadBalancer"
    }
  }

  merged_values = merge(local.default_traekif_values, var.traefik_values)
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  values = [yamlencode(local.merged_values)]
}
