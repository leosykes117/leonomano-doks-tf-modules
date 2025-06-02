locals {
  default_node_pool = one([
    for np in var.node_pools : np if np.default
  ])
}
