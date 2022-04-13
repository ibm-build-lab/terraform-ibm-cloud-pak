output "cp4ba_endpoint" {
  depends_on = [
    data.external.get_endpoints,
  ]
  description = "Use Host name of CP4BA instance to update in property \"cp4ba_endpoint\" with this information (in Skytap, use the IP 10.0.0.10 instead."
  value = var.enable_cp4ba && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint : ""
}

output "cp4ba_admin_username" {
  depends_on = [
    data.external.get_endpoints,
  ]
  description = "cp4ba_admin_username is a CP4BA identification used to login in CP4BA online service."
  value = var.enable_cp4ba && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.username : ""
}

output "cp4ba_admin_password" {
  depends_on = [
    data.external.get_endpoints,
  ]
  description = "cp4ba_admin_password will allowed a user to gain admission to the CP4BA online service."
  value = var.enable_cp4ba && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.password : ""
}