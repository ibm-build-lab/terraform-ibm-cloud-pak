// CP4DATA output parameters
output "cpd_url" {
  description = "Access your Cloud Pak for Data deployment at this URL."
  value = "https://${var.cpd_project_name}-cpd-${var.cpd_project_name}.${var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.ingress_hostname) 
  : join("", ibm_container_cluster.cluster.*.ingress_hostname)}"
}

output "cpd_user" {
  description = "Username for your Cloud Pak for Data deployment."
  value = "admin"
}

output "cpd_pass" {
  description = "Password for your Cloud Pak for Data deployment."
  value = "password"
}
