output "url" {
  description = "Access your Cloud Pak for Integration deployment at this URL."
  value       = module.cp4i.cp4i_endpoint
}

output "user" {
  description = "Username for your Cloud Pak for Integration deployment."
  value       = module.cp4i.cp4i_user
}

output "password" {
  description = "Password for your Cloud Pak for Integration deployment."
  value       = module.cp4i.cp4i_password
}


