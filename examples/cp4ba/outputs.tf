output "cp4ba_endpoint" {
  description = "Access your Cloud Pak for Business Automation deployment at this URL."
  value       = module.install_cp4ba.cp4ba_endpoint
}

output "cp4ba_admin_username" {
  description = "Username for your Cloud Pak for Business Automation deployment."
  value       = module.install_cp4ba.cp4ba_admin_username
}

output "cp4ba_admin_password" {
  description = "Password for your Cloud Pak for Business Automation deployment."
  value       = module.install_cp4ba.cp4ba_admin_password
}
