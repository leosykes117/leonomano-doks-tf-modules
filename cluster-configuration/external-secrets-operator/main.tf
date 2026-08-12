provider "kubernetes" {
  config_path    = var.kube_config_path
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

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "ssm_params_read_access" {
  statement {
    sid    = "AllowReadParamsUnderPath"
    effect = "Allow"
    actions = [
      "ssm:GetParameter*",
      "ssm:ListTagsForResource"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/account-configuration/${var.env}/*"
    ]
  }

  statement {
    sid    = "AllowWriteParamsUnderPath"
    effect = "Allow"
    actions = [
      "ssm:AddTagsToResource",
      "ssm:RemoveTagsFromResource",
      "ssm:PutParameter",
      "ssm:DeleteParameter*"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/account-configuration/${var.env}/*"
    ]
  }

  statement {
    sid    = "AllowReadAllParameters"
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "parameterstore_read_policy" {
  name = local.eso_aws_user_policy_name
  user = aws_iam_user.doks_eso_user.name

  policy = data.aws_iam_policy_document.ssm_params_read_access.json
}

resource "aws_iam_access_key" "doks_eso_aws_access" {
  user = aws_iam_user.doks_eso_user.name

  lifecycle {
    create_before_destroy = true
  }
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

  lifecycle {
    create_before_destroy = true
  }
}

output "aws_iam_user_name" {
  value       = aws_iam_user.doks_eso_user.name
  description = "IAM User Name for External Secrets Operator"
}

output "aws_iam_user_arn" {
  value       = aws_iam_user.doks_eso_user.arn
  description = "IAM User ARN for External Secrets Operator"
}
