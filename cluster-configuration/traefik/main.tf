terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
  }
}

variable "traefik_sets" {
  description = "set option for traefik helm chart"
  type        = list(map(any))
}

variable "traefik_values" {
  description = "Values in Yaml format for traefik"
  type        = string
  default     = ""
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

locals {
  default_traekif_sets = [{
    name  = "service.type"
    value = "LoadBalancer"
  }]

  merged_sets = concat(local.default_traekif_sets, var.traefik_sets)
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  set = local.merged_sets

  values = [var.traefik_values]
}
