output "db2_host_address" {
    depends_on = [
    data.external.get_endpoints,
  ]
  description = "Use Host name of Db2 instance to update in  property \"db2_Host_address\" with this information (in Skytap, use the IP 10.0.0.10 instead."
  value = var.enable_db2 && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint : ""
}

output "db2_ports" {
  depends_on = [
    data.external.get_endpoints,
  ]
  description = "Use these Ports for Db2 instance to update in  property \"db2PortNumber\" with this information (legacy-server)."
  value = var.enable_db2 && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.nodePort : ""
}
