data "aws_ssm_parameter" "do_token" {
  name = "/account-configuration/${var.env}/digital_ocean_token"
}

provider "digitalocean" {
  token = data.aws_ssm_parameter.do_token.value
}

data "digitalocean_regions" "available" {
  filter {
    key    = "available"
    values = ["true"]
  }
  depends_on = [data.aws_ssm_parameter.do_token]
}

data "digitalocean_kubernetes_versions" "this" {}

resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = var.cluster_name
  region  = var.do_region
  version = data.digitalocean_kubernetes_versions.this.latest_version

  dynamic "node_pool" {
    for_each = [local.default_node_pool]
    content {
      name       = node_pool.value.name
      size       = node_pool.value.size
      node_count = node_pool.value.auto_scale ? null : node_pool.value.node_count
      auto_scale = node_pool.value.auto_scale
      min_nodes  = node_pool.value.min_nodes
      max_nodes  = node_pool.value.max_nodes
      tags       = node_pool.value.tags
      labels     = node_pool.value.labels

      dynamic "taint" {
        for_each = lookup(node_pool.value, "taint", [])
        content {
          key    = lookup(taint.value, "key", null)
          value  = lookup(taint.value, "value", null)
          effect = lookup(taint.value, "effect", null)
        }
      }
    }
  }
}

resource "null_resource" "merge_kubeconfig" {
  depends_on = [digitalocean_kubernetes_cluster.k8s_cluster]

  provisioner "local-exec" {
    command = <<EOT
    doctl kubernetes cluster kubeconfig save ${digitalocean_kubernetes_cluster.k8s_cluster.name} -t ${data.aws_ssm_parameter.do_token.value}
    EOT
  }
}
