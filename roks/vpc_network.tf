resource "ibm_is_vpc" "vpc" {
  count = var.enable && var.on_vpc ? 1 : 0
  name  = "${var.project_name}-${var.environment}-vpc"
  tags = [
    "project:${var.project_name}",
    "env:${var.environment}",
    "owner:${var.owner}"
  ]
  resource_group           = data.ibm_resource_group.group.id
}

resource "ibm_is_public_gateway" "gateway" {
  count = var.enable && var.on_vpc ? local.max_size : 0
  name  = "${var.project_name}-${var.environment}-gateway-${format("%02s", count.index)}"
  vpc   = var.on_vpc ? ibm_is_vpc.vpc[0].id : 0
  zone  = var.vpc_zone_names[count.index]
  resource_group           = data.ibm_resource_group.group.id
}

resource "ibm_is_subnet" "subnet" {
  count                    = var.enable && var.on_vpc ? local.max_size : 0
  name                     = "${var.project_name}-${var.environment}-subnet-${format("%02s", count.index)}"
  zone                     = var.vpc_zone_names[count.index]
  vpc                      = var.on_vpc ? ibm_is_vpc.vpc[0].id : 0
  public_gateway           = ibm_is_public_gateway.gateway[count.index].id
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group_rule" "security_group_rule_tcp_k8s" {
  count     = var.enable && var.on_vpc ? local.max_size : 0
  group     = var.on_vpc ? ibm_is_vpc.vpc[0].default_security_group : 0
  direction = "inbound"

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

// Enable to ssh to the nodes
// resource "ibm_is_security_group_rule" "security_group_rule_ssh_k8s" {
//   group     = ibm_is_vpc.vpc.default_security_group
//   direction = "inbound"
//   tcp {
//     port_min = 22
//     port_max = 22
//   }
// }

// Enable to ping to the nodes
// resource "ibm_is_security_group_rule" "security_group_rule_icmp_k8s" {
//   group     = ibm_is_vpc.vpc.default_security_group
//   direction = "inbound"
//   icmp {
//     type = 8
//   }
// }
