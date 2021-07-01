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
# output "kubeconfig" {
#   value = data.ibm_container_cluster_config.cluster_config.config_file_path
# }

// CP4DATA output parameters
output "cpd_url" {
  description = "Access your Cloud Pak for Data deployment at this URL."
  value = "https://${var.cpd_project_name}-cpd-${var.cpd_project_name}.${module.cluster.ingress_hostname}"
}

output "cpd_user" {
  description = "Username for your Cloud Pak for Data deployment."
  value = "admin"
}

output "cpd_pass" {
  description = "Password for your Cloud Pak for Data deployment."
  value = "password"
}
