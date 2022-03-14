output "cp4ba_endpoint" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.enable_cp4ba && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint : ""
}

output "cp4ba_admin_username" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.enable_cp4ba && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.username : ""
}

output "cp4ba_admin_password" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.enable_cp4ba && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.password : ""
}