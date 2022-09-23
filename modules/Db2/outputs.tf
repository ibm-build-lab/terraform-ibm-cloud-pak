output "db2_host_address" {
    depends_on = [
    data.external.get_endpoints,
  ]
  description = "Use Host name of Db2 instance to update in  property \"db2_Host_address\" with this information (in Skytap, use the IP 10.0.0.10 instead)"
  value = var.enable_db2 && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.route : ""
}
output "db2_ip_address" {
  depends_on = [
    data.external.get_endpoints,
  ]
  description = "Use this external IP address to reach DB2 service."
  value = var.enable_db2 && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.ip_address : ""
}
output "db2_pod_name" {
    depends_on = [
    data.external.get_endpoints,
  ]
  description = "This pod for deploying Db2 schemas."
  value = var.enable_db2 && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.db2_pod_name : ""
}

output "db2_ports" {
    depends_on = [
    data.external.get_endpoints,
  ]
  description = "The ports to reach DB2 instance"
  value = var.enable_db2 && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.nodePort : ""
}