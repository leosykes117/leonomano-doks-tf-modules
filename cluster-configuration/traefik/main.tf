provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_ctx
}

locals {}

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "kubernetes_manifest" "tls_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "traefik-cert"
      namespace = kubernetes_namespace.traefik.metadata[0].name
    }
    spec = {
      secretName = "traefik-cert-tls"
      dnsNames = [
        "leonomano.com",
        "*.leonomano.com"
      ]
      issuerRef = {
        name = "letsencrypt-staging"
        kind = "ClusterIssuer"
      }
    }
  }
}

resource "random_password" "dashboard_pass" {
  length  = 16
  special = true
  provisioner "local-exec" {
    command    = "htpasswd -cbB .htpasswd admin ${self.result}"
    on_failure = fail
  }
}

resource "aws_ssm_parameter" "traefik_dashboard_hash" {
  name        = "/account-configuration/${var.env}/traefik/dashboard/auth/admin/password"
  description = "Traefik dashboard bcrypt password for admin user"
  type        = "SecureString"
  value = jsonencode({
    password = random_password.dashboard_pass.result
  })
}
