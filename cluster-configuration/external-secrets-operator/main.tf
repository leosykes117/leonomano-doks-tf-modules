provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kube_ctx
}

locals {
  eso_aws_user_name        = "${var.project_name}-${var.env}-eso-secret-store-aws"
  eso_aws_user_path        = "/${var.env}/${var.project_name}/cluster-configuration/external-secrets-operator/"
  eso_aws_user_policy_name = "${var.project_name}-${var.env}-eso-ssm-params-read-access"
  eso_k8s_namespace        = "external-secrets"
}

resource "aws_iam_user" "doks_eso_user" {
  name = local.eso_aws_user_name
  path = local.eso_aws_user_path
}

data "aws_iam_policy_document" "ssm_params_read_access" {
  statement {
    actions   = ["ssm:GetParameter*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_user_policy" "parameterstore_read_policy" {
  name = local.eso_aws_user_policy_name
  user = aws_iam_user.doks_eso_user.name

  policy = data.aws_iam_policy_document.ssm_params_read_access.json
}

resource "aws_iam_access_key" "doks_eso_aws_access" {
  user = aws_iam_user.doks_eso_user.name
}

resource "kubernetes_namespace" "external_secrets" {
  count = var.create_eso_namespace ? 1 : 0
  metadata {
    name = local.eso_k8s_namespace
  }
}

resource "kubernetes_secret" "aws_creds_doks_eso" {
  metadata {
    name      = "eso-${var.env}-aws-creds"
    namespace = local.eso_k8s_namespace
  }

  data = {
    "access-key-id"     = aws_iam_access_key.doks_eso_aws_access.id
    "secret-access-key" = aws_iam_access_key.doks_eso_aws_access.secret
  }

  type = "Opaque"
}
