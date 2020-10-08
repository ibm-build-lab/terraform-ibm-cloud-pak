output "endpoint" {
  value = var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.public_service_endpoint_url) : join("", ibm_container_cluster.cluster.*.public_service_endpoint_url)
}

output "id" {
  value = var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.id) : join("", ibm_container_cluster.cluster.*.id)
}

output "name" {
  value = var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.resource_name) : join("", ibm_container_cluster.cluster.*.resource_name)
}

output "config" {
  value = data.ibm_container_cluster_config.cluster_config
}

// output "resource_group" {
//   value = ibm_resource_group.group.name
// }

// output "cluster" {
//   value = var.on_vpc ? data.ibm_container_vpc_cluster.cluster.0 : data.ibm_container_cluster.cluster.0
// }
