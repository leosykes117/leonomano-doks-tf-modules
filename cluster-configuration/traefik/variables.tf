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

variable "kube_ctx" {
  description = "Kubernetes context"
  type        = string
  default     = "minikube"
}
