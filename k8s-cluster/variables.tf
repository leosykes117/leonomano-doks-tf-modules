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

variable "do_region" {
  description = "Region where the cluster will be created"
  type        = string
  default     = "nyc1"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "node_pools" {
  description = "A list of node pool definitions"
  type = list(object({
    name       = string
    size       = string
    default    = optional(bool, false)
    node_count = optional(number, 1)
    auto_scale = optional(bool, false)
    min_nodes  = optional(number, 1)
    max_nodes  = optional(number, 1)
    tags       = optional(list(string), null)
    labels     = optional(map(string), null)
    taint      = optional(list(string), [])
  }))
  default = [{
    name       = "default-pool"
    default    = true
    size       = "s-2vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
    tags       = ["default-nodepool"]
  }]
}
