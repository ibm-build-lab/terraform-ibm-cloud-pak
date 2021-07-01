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

// output "cluster" {
//   value = module.cluster.cluster
// }

// CP4APP output parameters
output "cp4app_installer_namespace" {
  value = module.cp4app.installer_namespace
}
output "cp4app_endpoint" {
  value = module.cp4app.endpoint
}
output "cp4app_advisor_ui_endpoint" {
  value = module.cp4app.advisor_ui_endpoint
}
output "cp4app_navigator_ui_endpoint" {
  value = module.cp4app.navigator_ui_endpoint
}
