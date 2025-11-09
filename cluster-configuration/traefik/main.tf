terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  set = [{
    name  = "service.type"
    value = "LoadBalancer"
  }]
}
