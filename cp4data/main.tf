locals {
  ibm_operator_catalog              = file(join("/", [path.module, "files", "ibm-operator-catalog.yaml"])) 
  opencloud_operator_catalog        = file(join("/", [path.module, "files", "opencloud-operator-catalog.yaml"])) 
  subscription                      = file(join("/", [path.module, "files", "subscription.yaml"])) 
  operator_group                    = file(join("/", [path.module, "files", "operator-group.yaml"])) 

  on_vpc_ready = var.on_vpc ? var.portworx_is_ready : null

  storageclass = {
    "lite"               = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "dv"                 = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "spark"              = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "wkc"                = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "wsl"                = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "wml"                = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "aiopenscale"        = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "cde"                = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "streams"            = var.on_vpc ? "portworx-shared-gp-allow" : "ibmc-file-gold-gid",
    "dmc"                = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "db2wh"              = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "datagate"           = var.on_vpc ? "portworx-db2-rwx-sc" : "ibmc-file-gold-gid",
    "big-sql"            = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
    "rstudio"            = var.on_vpc ? "portworx-shared-gp3" : "ibmc-file-gold-gid",
  }
  override = {
    "lite"               = var.on_vpc ? "portworx" : "",
    "dv"                 = var.on_vpc ? "portworx" : "",
    "spark"              = var.on_vpc ? "portworx" : "",
    "wkc"                = var.on_vpc ? "portworx" : "",
    "wsl"                = var.on_vpc ? "portworx" : "",
    "wml"                = var.on_vpc ? "portworx" : "",
    "aiopenscale"        = var.on_vpc ? "portworx" : "",
    "cde"                = var.on_vpc ? "portworx" : "",
    "streams"            = var.on_vpc ? "portworx" : "",
    "dmc"                = var.on_vpc ? "portworx" : "",
    "db2wh"              = "",
    "datagate"           = var.on_vpc ? "portworx" : "",
    "big-sql"            = var.on_vpc ? "portworx" : "",
    "rstudio"            = var.on_vpc ? "portworx" : "",
  }
}

resource "null_resource" "install_cp4d_operator" {
  count = var.enable ? 1 : 0

  triggers = {
    force_to_run                              = var.force ? timestamp() : 0
    namespace_sha1                            = sha1(local.namespace)
    docker_params_sha1                        = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ibm_operator_catalog_sha1                 = sha1(local.ibm_operator_catalog)
    opencloud_operator_catalog_sha1           = sha1(local.opencloud_operator_catalog)
    subscription_sha1                         = sha1(local.subscription)
    operator_group_sha1                       = sha1(local.operator_group)
  }

  provisioner "local-exec" {
    command     = "./install_cp4d.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      FORCE                         = var.force
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.cpd_project_name
      IBM_OPERATOR_CATALOG          = local.ibm_operator_catalog
      OPENCLOUD_OPERATOR_CATALOG    = local.opencloud_operator_catalog
      SUBSCRIPTION                  = local.subscription
      DOCKER_REGISTRY_PASS          = local.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry
      OPERATOR_GROUP                = local.operator_group
    }
  }

  depends_on = [
    local.on_vpc_ready, // Something needs to be done here... perhaps on_vpc check?
    null_resource.prereqs_checkpoint
  ]
}

# Install control plane
resource "null_resource" "install_lite" {
  count = var.accept_cpd_license ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} lite ${local.storageclass["lite"]} ${local.override["lite"]}"
  }

  depends_on = [
    null_resource.install_cp4d_operator
  ]
}

# Reencrypt route
resource "null_resource" "reencrypt_route" {
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./reencrypt_route.sh ${var.cpd_project_name}"
  }

  depends_on = [
    null_resource.install_lite
  ]
}

resource "null_resource" "install_spark" {
  count = var.accept_cpd_license && var.install_spark ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} spark ${local.storageclass["spark"]} ${local.override["spark"]}"
  }

  depends_on = [
    null_resource.install_lite
  ]
}

resource "null_resource" "install_dv" {
  count = var.accept_cpd_license && var.install_data_virtualization ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} dv ${local.storageclass["dv"]} ${local.override["dv"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
  ]
}

resource "null_resource" "install_wkc" {
  count = var.accept_cpd_license && var.install_watson_knowledge_catalog ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} wkc ${local.storageclass["wkc"]} ${local.override["wkc"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
  ]
}

resource "null_resource" "install_wsl" {
  count = var.accept_cpd_license && var.install_watson_studio ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} wsl ${local.storageclass["wsl"]} ${local.override["wsl"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
  ]
}

resource "null_resource" "install_wml" {
  count = var.accept_cpd_license && var.install_watson_machine_learning ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} wml ${local.storageclass["wml"]} ${local.override["wml"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
  ]
}

resource "null_resource" "install_aiopenscale" {
  count = var.accept_cpd_license && var.install_watson_open_scale ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} aiopenscale ${local.storageclass["aiopenscale"]} ${local.override["aiopenscale"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
  ]
}

resource "null_resource" "install_cde" {
  count = var.accept_cpd_license && var.install_analytics_dashboard ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} cde ${local.storageclass["cde"]} ${local.override["cde"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
  ]
}

resource "null_resource" "install_streams" {
  count = var.accept_cpd_license && var.install_streams ? 1 : 0

  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} streams ${local.storageclass["streams"]} ${local.override["streams"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
    null_resource.install_cde,
  ]
}

resource "null_resource" "install_dmc" {
  count = var.accept_cpd_license && var.install_db2_data_management ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} dmc ${local.storageclass["dmc"]} ${local.override["dmc"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
    null_resource.install_cde,
    null_resource.install_streams,
  ]
}

resource "null_resource" "install_db2wh" {
  count = var.accept_cpd_license && var.install_db2_warehouse ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} db2wh ${local.storageclass["db2wh"]} ${local.override["db2wh"]}"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
    null_resource.install_cde,
    null_resource.install_streams,
    null_resource.install_dmc,
  ]
}


resource "null_resource" "install_datagate" {
  count = var.accept_cpd_license && var.install_db2_data_gate ? 1 : 0

  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} datagate ${local.storageclass["datagate"]} ${local.override["datagate"]}"
  }
  
  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
    null_resource.install_cde,
    null_resource.install_streams,
    null_resource.install_dmc,
    null_resource.install_db2wh,
  ]
}


resource "null_resource" "install_big_sql" {
  count = var.accept_cpd_license && var.install_big_sql ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} big-sql ${local.storageclass["big-sql"]} ${local.override["big-sql"]}"
  }
  
  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
    null_resource.install_cde,
    null_resource.install_streams,
    null_resource.install_dmc,
    null_resource.install_db2wh,
    null_resource.install_datagate,
  ]
}

resource "null_resource" "install_rstudio" {
  count = var.accept_cpd_license && var.install_rstudio ? 1 : 0
  
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_cpdservice_generic.sh ${var.cpd_project_name} rstudio ${local.storageclass["rstudio"]} ${local.override["rstudio"]}"
  }
  
  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
    null_resource.install_cde,
    null_resource.install_streams,
    null_resource.install_dmc,
    null_resource.install_db2wh,
    null_resource.install_datagate,
    null_resource.install_big_sql,
  ]
}

resource "null_resource" "get_endpoint" {
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./get_endpoints.sh"
  }

  depends_on = [
    null_resource.install_lite,
    null_resource.install_spark,
    null_resource.install_dv,
    null_resource.install_wkc,
    null_resource.install_wsl,
    null_resource.install_wml,
    null_resource.install_aiopenscale,
    null_resource.install_cde,
    null_resource.install_streams,
    null_resource.install_dmc,
    null_resource.install_db2wh,
    null_resource.install_datagate,
    null_resource.install_big_sql,
    null_resource.install_rstudio
  ]
}