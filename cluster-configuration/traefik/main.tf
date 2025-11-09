terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "do-sfo2-dev-leonomano-projects"
}

variable "traefik_values" {
  description = "Map of values that will be merged with the default values"
  type        = any
  default     = {}
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

locals {
  default_traekif_values = {}

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

resource "kubernetes_manifest" "tls_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "traefik-cert"
      namespace = "traefik"
    }
    spec = {
      secretName = "traefik-cert-tls"
      dnsNames = [
        "gateway.leonomano.com"
      ]
      issuerRef = {
        name = "letsencrypt-staging"
        kind = "ClusterIssuer"
      }
    }
  }
}
