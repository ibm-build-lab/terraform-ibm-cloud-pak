output "endpoint" {
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint_cp4app : ""
}
output "advisor_ui_endpoint" {
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint_advisor_ui : ""
}
output "navigator_ui_endpoint" {
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint_navigator_ui : ""
}
