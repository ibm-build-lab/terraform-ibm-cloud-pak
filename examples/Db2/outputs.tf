output "db2_host_address" {
  description = "Use Host name of Db2 instance to update in  property \"db2_Host_address\" with this information (in Skytap, use the IP 10.0.0.10 instead."
  value = module.Db2.db2_host_address
}

output "db2_ports" {
  description = "Use these Ports for Db2 instance to update in  property \"db2PortNumber\" with this information (legacy-server)."
  value = module.Db2.db2_ports
}
