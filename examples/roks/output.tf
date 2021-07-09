//Output Parameters

output "endpoint" {
  value = module.cluster.endpoint
}

output "id" {
  value = module.cluster.id
}

output "name" {
  value = module.cluster.name
}

// output "config" {
//   value = module.cluster.config
// }

// output "config_file_path" {
//   value = data.ibm_container_cluster_config.cluster_config.config_file_path
// }

output "vlan_number" {
  value = module.cluster.vlan_number
}
