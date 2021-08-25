output "namespace" {
  value = var.enable ? local.mcm_namespace : ""
}

output "endpoint" {
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.host : ""
}

output "user" {
  // value = var.enable && length(data.kubernetes_secret.mcm_credentials) > 0 ? data.kubernetes_secret.mcm_credentials.0.data.admin_username : ""
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.username : ""
}

output "password" {
  // value = var.enable && length(data.kubernetes_secret.mcm_credentials) > 0 ? data.kubernetes_secret.mcm_credentials.0.data.admin_password : ""
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.password : ""
}

