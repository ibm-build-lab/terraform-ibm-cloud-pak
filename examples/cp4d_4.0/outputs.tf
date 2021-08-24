output "cpd_url" {
  description = "Access your Cloud Pak for Data deployment at this URL."
  value       = "$(oc get routes -n zen)"
}

output "cpd_user" {
  description = "Username for your Cloud Pak for Data deployment."
  value       = "admin"
}

output "cpd_pass" {
  description = "Password for your Cloud Pak for Data deployment."
  value       = "$(oc extract secret/admin-user-details --keys=initial_admin_password --to=- -n zen)"
}