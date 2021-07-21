//locals {
//  catalogsource_content = templatefile("../templates/CatalogSource.yaml")
//
//  AutomationBase = templatefile("../templates/AutomationBase.yaml", {
//    namespace                = "cp4ba",
//  })
//
//  subscription_content = templatefile("../templates/Subscription.yaml", {
//    namespace                = "cp4ba",
//  })
//}
//
//resource "local_file" "CatalogSource" {
//  content  = local.catalogsource_content
//  filename = "${path.modules}/rendered_files/CatalogSource.yaml"
//}
//
//resource "local_file" "AutomationBase" {
//  content  = local.AutomationBase
//  filename = "${path.modules}/rendered_files/AutomationBase.yaml"
//}
//
//resource "local_file" "Subscription" {
//  content  = local.subscription_content
//  filename = "${path.modules}/rendered_files/Subscription.yaml"
//}