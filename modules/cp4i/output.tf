output "endpoint" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.result.endpoint : ""
}

output "user" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.result.username : ""
}

output "password" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.result.password : ""
}
