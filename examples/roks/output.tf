output "endpoint" {
  value = module.cluster.endpoint
}

output "id" {
  value = module.cluster.id
}

output "name" {
  value = module.cluster.name
}

output "vlan_number" {
  value = module.cluster.vlan_number
}

// Kubeconfig downloaded by this module
output "config_file_path" {
  value = data.ibm_container_cluster_config.cluster_config.config_file_path
}
  
output "cluster_config" {
  value = data.ibm_container_cluster_config.cluster_config
}
