data "external" "vlans" {
  count   = var.enable && ! var.on_vpc && (length(var.private_vlan_number) + length(var.private_vlan_number) == 0) ? 1 : 0
  program = ["sh", "-c", "${path.module}/files/vlan.sh ${var.datacenter} -v -o json"]
}

locals {
  private_vlan_number = length(var.private_vlan_number) != 0 ? var.private_vlan_number : data.external.vlans.0.result.private
  public_vlan_number  = length(var.public_vlan_number) != 0 ? var.public_vlan_number : data.external.vlans.0.result.public
}
