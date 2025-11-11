terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

variable "env" {
  description = "Project Environment"
  type        = string
  default     = "dev"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "do-sfo2-dev-leonomano-projects"
}

locals {
  namespace                                         = "cert-manager"
  external_secret_cloudflare_token_name             = "${var.env}-clusterissuer-solver-cloudflare-token"
  external_secrets_cloudflare_token_secret_key_name = "api-token"
}

resource "kubernetes_manifest" "external-secret-cloudflare-token" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = local.external_secret_cloudflare_token_name
      namespace = local.namespace
    }
    spec = {
      refreshInterval = "24h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "aws-dev-parameter-store"
      }
      target = {
        name           = local.external_secret_cloudflare_token_name
        deletionPolicy = "Delete"
      }
      data = [
        {
          secretKey = local.external_secrets_cloudflare_token_secret_key_name
          remoteRef = {
            key = "/account-configuration/${var.env}/cluster-issuer-cloudflare-token"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "staging-cluster-issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
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
                name = local.external_secret_cloudflare_token_name
                key  = local.external_secrets_cloudflare_token_secret_key_name
              }
            }
          }
        }]
      }
    }
  }
}
