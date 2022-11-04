output "cpd_url" {
  description = "Access your Cloud Pak for Data deployment at this URL."
  value       = module.cp4data.endpoint
}

output "cpd_user" {
  description = "Username for your Cloud Pak for Data deployment."
  value       = module.cp4data.user
}

output "cpd_password" {
  description = "Password for your Cloud Pak for Data deployment."
  value       = module.cp4data.password
}
