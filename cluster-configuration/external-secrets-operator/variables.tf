variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "leonomano-do-k8s-cluster"
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

variable "aws_account_id" {
  description = "AWS account id to scope IAM resources to (optional, but recommended)"
  type        = string
}

variable "k8s_cluster_name" {
  description = "Kubernetes Cluster Name"
  type        = string
  default     = "minikube"
}
