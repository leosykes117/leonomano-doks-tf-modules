locals {
  eso_aws_user_name        = "${var.project_name}-${var.env}-eso-secret-store-aws"
  eso_aws_user_path        = "/${var.env}/${var.project_name}/cluster-configuration/external-secrets-operator/"
  eso_aws_user_policy_name = "${var.project_name}-${var.env}-eso-ssm-params-read-access"
}

resource "aws_iam_user" "k8s_eso_user" {
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
  user = aws_iam_user.k8s_eso_user.name

  policy = data.aws_iam_policy_document.ssm_params_read_access.json
}

resource "aws_iam_access_key" "k8s_eso_aws_access" {
  user = aws_iam_user.k8s_eso_user.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ssm_parameter" "k8s_eso_ssm_secret_store_access_credentials" {
  name        = "/account-configuration/${var.env}/external-secrets-operator/secret-store-access-credentials"
  description = "Access credentials for External Secrets Operator to read/write parameters in AWS Parameter Store"
  type        = "SecureString"
  value = jsonencode({
    access-key-id     = aws_iam_access_key.k8s_eso_aws_access.id,
    secret-access-key = aws_iam_access_key.k8s_eso_aws_access.secret
  })
}
