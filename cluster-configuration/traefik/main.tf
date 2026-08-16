locals {}

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
