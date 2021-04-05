data "ibm_resource_group" "group" {
  name = var.resource_group
  region     = local.region
}

// resource "ibm_resource_group" "group" {
//   name = "${var.project_name}-${var.environment}-group"
// }
