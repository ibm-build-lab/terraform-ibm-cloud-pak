// General output parameters
output "resource_group" {
  value = var.resource_group
}

// ROKS output parameters
output "cluster_endpoint" {
  value = module.cluster.endpoint
}
output "cluster_id" {
  value = local.enable_cluster ? module.cluster.id : var.cluster_id
}
output "cluster_name" {
  value = local.enable_cluster ? module.cluster.name : ""
}
output "kubeconfig" {
  value = data.ibm_container_cluster_config.cluster_config.config_file_path
}

// output "cluster_config" {
//   value = module.cluster.config
// }

// CP4MCM output parameters
output "cp4mcm_endpoint" {
  value = module.cp4mcm.endpoint
}
output "cp4mcm_user" {
  value = module.cp4mcm.user
}
output "cp4mcm_password" {
  value = module.cp4mcm.password
}
output "cp4mcm_namespace" {
  value = module.cp4mcm.namespace
}
