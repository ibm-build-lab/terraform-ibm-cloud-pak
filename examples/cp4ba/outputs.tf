output "cp4ba_endpoint" {
  description = "Access your Cloud Pak for Business Automation deployment at this URL."
  value       = module.cp4ba.cp4ba_endpoint
}

output "cp4ba_user" {
  description = "Username for your Cloud Pak for Business Automation deployment."
  value       = module.cp4ba.cp4ba_user
}

output "cp4ba_password" {
  description = "Password for your Cloud Pak for Business Automation deployment."
  value       = module.cp4ba.cp4ba_password
}
