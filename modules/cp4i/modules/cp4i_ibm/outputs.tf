output "cp4i_endpoint" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.result.endpoint : ""
}

output "cp4i_user" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.result.username : ""
}

output "cp4i_password" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.result.password : ""
}
