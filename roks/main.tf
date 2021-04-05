data "ibm_resource_group" "group" {
  name = var.resource_group
}

// resource "ibm_resource_group" "group" {
//   name = "${var.project_name}-${var.environment}-group"
// }
