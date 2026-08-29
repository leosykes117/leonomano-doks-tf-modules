output "doks_cluster" {
  description = ""
  value = {
    id       = digitalocean_kubernetes_cluster.k8s_cluster.id
    name     = digitalocean_kubernetes_cluster.k8s_cluster.name
    endpoint = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
    ipv4     = digitalocean_kubernetes_cluster.k8s_cluster.ipv4_address
    version  = digitalocean_kubernetes_cluster.k8s_cluster.version

    node_pool = {
      id         = digitalocean_kubernetes_cluster.k8s_cluster.node_pool[0].id
      name       = digitalocean_kubernetes_cluster.k8s_cluster.node_pool[0].name
      node_count = digitalocean_kubernetes_cluster.k8s_cluster.node_pool[0].node_count
      nodes = [
        for n in digitalocean_kubernetes_cluster.k8s_cluster.node_pool[0].nodes : {
          name       = n.name
          status     = n.status
          created_at = n.created_at
        }
      ]
    }
  }
}
