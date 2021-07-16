output "endpoint" {
  value = ! var.enable ? "" : var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.public_service_endpoint_url) : join("", ibm_container_cluster.cluster.*.public_service_endpoint_url)
}

// Used for cp4d output
output "ingress_hostname" {
  value = ! var.enable ? "" : var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.ingress_hostname) : join("", ibm_container_cluster.cluster.*.ingress_hostname)
}

output "id" {
  value = var.enable ? (var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.id) : join("", ibm_container_cluster.cluster.*.id)) : ""
}

output "name" {
  value = ! var.enable ? "" : var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.resource_name) : join("", ibm_container_cluster.cluster.*.resource_name)
}

// output "config" {
//   value = var.enable && length(data.ibm_container_cluster_config.cluster_config) > 0 ? data.ibm_container_cluster_config.cluster_config.0 : null
// }

output "resource_group" {
  value = data.ibm_resource_group.group
}

output "vlan_number" {
  value = {
    private = local.private_vlan_number
    public  = local.public_vlan_number
  }
}

// output "cluster" {
//   value = var.on_vpc ? data.ibm_container_vpc_cluster.cluster.0 : data.ibm_container_cluster.cluster.0
// }
