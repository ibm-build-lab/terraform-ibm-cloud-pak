locals {
  security_context_constraints_content = templatefile("../templates/security_context_constraints.tmpl.yaml", {
    namespace = local.namespace,
  })

  installer_sensitive_data = templatefile("../templates/installer_sensitive_data.tmpl.yaml", {
    namespace                        = local.namespace,
    docker_username_encoded          = base64encode(local.docker_username),
    docker_registry_password_encoded = base64encode(local.entitled_registry_key),
  })

  installer_job_content = templatefile("../templates/installer_job.tmpl.yaml", {
    namespace          = local.namespace,
    storage_class_name = local.storage_class_name,
    docker_registry    = local.docker_registry,

    // Modules to deploy
    install_watson_knowledge_catalog = local.install_watson_knowledge_catalog,
    install_watson_studio            = local.install_watson_studio,
    install_watson_machine_learning  = local.install_watson_machine_learning,
    install_watson_open_scale        = local.install_watson_open_scale,
    install_data_virtualization      = local.install_data_virtualization,
    install_streams                  = local.install_streams,
    install_analytics_dashboard      = local.install_analytics_dashboard,
    install_spark                    = local.install_spark,
    install_db2_warehouse            = local.install_db2_warehouse,
    install_db2_data_gate            = local.install_db2_data_gate,
    install_rstudio                  = local.install_rstudio,
    install_db2_data_management      = local.install_db2_data_management,
  })
}

resource "local_file" "security_context_constraints" {
  content  = local.security_context_constraints_content
  filename = "${path.module}/rendered_files/security_context_constraints.yaml"
}

resource "local_file" "installer_sensitive_data" {
  content  = local.installer_sensitive_data
  filename = "${path.module}/rendered_files/installer_sensitive_data.yaml"
}

resource "local_file" "installer_job" {
  content  = local.installer_job_content
  filename = "${path.module}/rendered_files/installer_job.yaml"
}

locals {
  namespace                        = "cloudpak4data"
  docker_username                  = "ekey"
  docker_registry_password         = "password"
  storage_class_name               = "ibmc-file-custom-gold-gid"
  docker_registry                  = join("/", ["cp.icr.io", "cp", "cpd"])
  install_watson_knowledge_catalog = false
  install_watson_studio            = false
  install_watson_machine_learning  = false
  install_watson_open_scale        = false
  install_data_virtualization      = false
  install_streams                  = false
  install_analytics_dashboard      = false
  install_spark                    = false
  install_db2_warehouse            = false
  install_db2_data_gate            = false
  install_rstudio                  = false
  install_db2_data_management      = false
}

