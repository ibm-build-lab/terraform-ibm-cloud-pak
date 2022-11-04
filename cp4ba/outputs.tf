output "cp4ba_endpoint" {
  description = "Use Host name of CP4BA instance to update in property \"cp4ba_endpoint\" with this information (in Skytap, use the IP 10.0.0.10 instead."
  value       = module.install_cp4ba.cp4ba_endpoint
}

output "cp4ba_admin_username" {
  description = "cp4ba_admin_username is a CP4BA identification used to login in CP4BA online service."
  value       = module.install_cp4ba.cp4ba_admin_username
}

output "cp4ba_admin_password" {
  description = "cp4ba_admin_password will allowed a user to gain admission to the CP4BA online service."
  value       = module.install_cp4ba.cp4ba_admin_password
}

