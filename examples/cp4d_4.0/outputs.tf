output "login_command" {
  value = module.ocp.login_cmd
}

output "cpd_url" {
  description = "Access your Cloud Pak for Data deployment at this URL."
  value       = "$(oc get routes -n ${var.cpd_namespace})"
}

output "cpd_url_username" {
  description = "Username for your Cloud Pak for Data deployment."
  value       = "admin"
}

output "cpd_url_password" {
  description = "Password for your Cloud Pak for Data deployment."
  value       = "$(oc extract secret/admin-user-details --keys=initial_admin_password --to=-)"
}