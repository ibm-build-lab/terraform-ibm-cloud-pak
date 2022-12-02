# resource "null_resource" "create-dir" {
#   triggers = {
#     installer_workspace = var.installer_workspace
#   }
#   provisioner "local-exec" {
#     when    = create
#     command = <<EOF
# test -e ${self.triggers.installer_workspace} || mkdir ${self.triggers.installer_workspace}
# EOF
#   }
# }

module "cpd" {
  #   count                     = var.accept_cpd_license == "accept" ? 1 : 0
  source                    = "./.."
  openshift_api             = var.openshift_api
  openshift_username        = var.openshift_username
  openshift_password        = var.openshift_password
  openshift_token           = var.openshift_token
  installer_workspace       = var.installer_workspace
  accept_cpd_license        = var.accept_cpd_license
  cpd_external_registry     = var.cpd_external_registry
  cpd_external_username     = var.cpd_external_username
  cpd_api_key               = var.cpd_api_key
  cpd_namespace             = var.cpd_namespace
  storage_option            = var.storage_option
  cpd_platform              = var.cpd_platform
  data_virtualization       = var.data_virtualization
  analytics_engine          = var.analytics_engine
  watson_knowledge_catalog  = var.watson_knowledge_catalog
  watson_studio             = var.watson_studio
  watson_machine_learning   = var.watson_machine_learning
  watson_ai_openscale       = var.watson_ai_openscale
  cognos_dashboard_embedded = var.cognos_dashboard_embedded
  datastage                 = var.datastage
  db2_warehouse             = var.db2_warehouse
  cognos_analytics          = var.cognos_analytics
  spss_modeler              = var.spss_modeler
  data_management_console   = var.data_management_console
  db2_oltp                  = var.db2_oltp
  master_data_management    = var.master_data_management
  db2_aaservice             = var.db2_aaservice
  decision_optimization     = var.decision_optimization
  login_cmd                 = var.login_cmd
  rosa_cluster              = var.rosa_cluster
}