output "namespace" {
  value = var.enable ? local.mcm_namespace : ""
}

output "endpoint" {
  value = var.enable && length(data.external.kubectl_get_endpoint) > 0 ? data.external.kubectl_get_endpoint.0.result.host : ""
}

output "user" {
  // value = var.enable && length(data.kubernetes_secret.mcm_credentials) > 0 ? data.kubernetes_secret.mcm_credentials.0.data.admin_username : ""
  value = var.enable && length(data.external.kubectl_get_mcm_admin_username) > 0 ? data.external.kubectl_get_mcm_admin_username.0.results.username : ""
}

output "password" {
  // value = var.enable && length(data.kubernetes_secret.mcm_credentials) > 0 ? data.kubernetes_secret.mcm_credentials.0.data.admin_password : ""
  value = var.enable && length(data.external.kubectl_get_mcm_admin_password) > 0 ? data.external.kubectl_get_mcm_admin_password.0.results.password : ""
}

