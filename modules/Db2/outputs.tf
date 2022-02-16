output "db2_project_name" {
  value = var.db2_project_name
  description = "The namespace/project for Db2"
}

output "db2_admin_user_password" {
  value = var.db2_admin_user_password
  description = "Db2 admin user password defined in LDAP"
}

output "db2_admin_username" {
  value = var.db2_admin_username
  description = "Db2 admin username defined in LDAP"
}

//output "db2_host_name" {
//  value = module.db2_host_name
//  description = "Host name of Db2 instance"
//}
//
//output "db2_host_ip" {
//  value = var.db2_host_ip
//  description = "IP address for the Db2"
//}
//
//output "db2_port_number" {
//  value = var.db2_port_number
//  description = "Port for Db2 instance"
//}
//
//output "db2_standard_license_key" {
//  value = var.db2_standard_license_key
//  description = "The standard license key for the Db2 database product"
//}