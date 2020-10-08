resource "ibm_container_cluster" "cluster" {
  count             = ! var.on_vpc ? 1 : 0
  name              = "${var.project_name}-${var.environment}-cluster"
  datacenter        = var.datacenter
  default_pool_size = var.size
  machine_type      = var.flavor
  hardware          = "shared"
  kube_version      = local.roks_version
  resource_group_id = data.ibm_resource_group.group.id
  public_vlan_id    = var.public_vlan_number
  private_vlan_id   = var.private_vlan_number
  // gateway_enabled          = "true"
  // public_service_endpoint  = "true"
  // private_service_endpoint = "true"

  entitlement = "cloud_pak"

  tags = [
    "project:${var.project_name}",
    "env:${var.environment}",
    "owner:${var.owner}"
  ]
}
