variable "env" {
  description = "Project Environment"
  type        = string
  default     = "dev"
}

variable "kube_config_path" {
  description = "Kubernetes config path"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_ctx" {
  description = "Kubernetes context"
  type        = string
  default     = "minikube"
}
