output "aws_iam_user_name" {
  value       = aws_iam_user.k8s_eso_user.name
  description = "IAM User Name for External Secrets Operator"
}

output "aws_iam_user_arn" {
  value       = aws_iam_user.k8s_eso_user.arn
  description = "IAM User ARN for External Secrets Operator"
}

output "aws_iam_user_policy_name" {
  value       = aws_iam_user_policy.parameterstore_read_policy.name
  description = "IAM User Policy Name for External Secrets Operator"
}

output "eso_secret_store_credentials_ssm_param_name" {
  value       = aws_ssm_parameter.k8s_eso_ssm_secret_store_access_credentials.name
  description = "SSM param name with access credentials for External Secrets Operator to read/write parameters in AWS Parameter Store"
}
