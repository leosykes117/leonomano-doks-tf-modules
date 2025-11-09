terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
  }
}

variable "cert_manager_values" {
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
  default_values = {
    crds = {
      enabled = true
    }
  }

  merged_values = merge(local.default_values, var.cert_manager_values)
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  chart            = "oci://quay.io/jetstack/charts/cert-manager"
  version          = "v1.19.1"
  create_namespace = true

  values = [yamlencode(local.merged_values)]
}
