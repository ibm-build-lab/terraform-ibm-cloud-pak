output "namespace" {
  value = var.enable ? local.namespace : ""
}

// output "endpoint" {
//   value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint : ""
// }

// output "user" {
//   value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.username : ""
// }

// output "password" {
//   value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.password : ""
// }

