output "url" {
  description = "Access your Cloud Pak for Integration deployment at this URL."
  value       = module.cp4i.endpoint
}

output "user" {
  description = "Username for your Cloud Pak for Integration deployment."
  value       = module.cp4i.user
}

output "password" {
  description = "Password for your Cloud Pak for Integration deployment."
  value       = module.cp4i.password
}


