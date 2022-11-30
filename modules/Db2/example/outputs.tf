output "db2_host_address" {
  description = "Db2 Internal host url address"
  value = module.Db2.db2_host_address
}

output "db2_pod_name" {
  description = "Pod for deploying Db2 schemas."
  value = module.Db2.db2_pod_name
}

output "db2_ip_address" {
  description = "Db2 Host external IP address"
  value = module.Db2.db2_ip_address
}

output "db2_ports" {
  description = "Ports to reach Db2 instance."
  value = module.Db2.db2_ports
}


