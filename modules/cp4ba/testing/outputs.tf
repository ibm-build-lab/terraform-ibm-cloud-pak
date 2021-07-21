//output "namespace" {
//  value = var.namespace
//}
//
//output "cluster_name_id" {
//  value = var.cluster_name_id
//}
//
//output "entitled_registry_user_email" {
//  value = var.entitled_registry_user_email
//}
//
////output "config_file_path" {
////  config_file_path = var.cluster_config_path
////}
//
//output "ibm_resource_group" {
//  value = var.resource_group_name
//}
//

//output "setting_platform" {
//  value = "${data.n}"
//}

output "name" {
  value = module.cluster.name
}

output "id" {
  value = module.cluster.id
}

output "vlan_number" {
  value = module.cluster.vlan_number
}