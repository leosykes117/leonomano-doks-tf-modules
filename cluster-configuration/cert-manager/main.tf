terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
  }
}

variable "env" {
  description = "Project Environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
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

data "aws_ssm_parameter" "cloudflare_token" {
  name = "/account-configuration/${var.env}/cluster-issuer-cloudflare-token"
}


resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  chart            = "oci://quay.io/jetstack/charts/cert-manager"
  version          = "v1.19.1"
  create_namespace = true

  values = [yamlencode(local.merged_values)]
}

resource "kubernetes_manifest" "cloudflare_token" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name = "cloudflare-api-token-secret"
    }
    type = "Opaque"
    stringData = {
      api-token = "${data.aws_ssm_parameter.cloudflare_token.value}"
    }
  }
}

resource "kubernetes_manifest" "staging-cluster-issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
      #namespace = "default"
    }
    spec = {
      acme = {
        email  = "leo.aremtz98@gmail.com"
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-staging-key"
        }
        solvers = [{
          dns01 = {
            cloudflare = {
              email = "leo.aremtz98@gmail.com"
              apiTokenSecretRef = {
                name = kubernetes_manifest.cloudflare_token.object.metadata.name
                key  = "api-token"
              }
            }
          }
        }]
      }
    }
  }
}
