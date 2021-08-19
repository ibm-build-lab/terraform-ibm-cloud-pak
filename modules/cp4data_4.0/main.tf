locals {
  # ibm_operator_catalog              = file(join("/", [path.module, "files", "ibm-operator-catalog.yaml"]))
  # opencloud_operator_catalog        = file(join("/", [path.module, "files", "opencloud-operator-catalog.yaml"]))
  # subscription                      = file(join("/", [path.module, "files", "subscription.yaml"]))
  # operator_group                    = file(join("/", [path.module, "files", "operator-group.yaml"]))

  # on_vpc_ready = var.on_vpc ? var.portworx_is_ready : 1
}

##############################
# Install Bedrock Zen Operator
#############################


resource "null_resource" "bedrock_zen_operator" {
  count = var.accept_cpd_license == "yes" ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      ENTITLEMENT_USER = var.entitled_registry_user_email
      ENTITLEMENT_KEY = var.entitled_registry_key
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      IBMCLOUD_APIKEY = var.ibmcloud_api_key
      # IBMCLOUD_RG_NAME = local.resource_group_name
      # REGION = local.region
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_bedrock_zen_operator.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
  ]
}

resource "null_resource" "install_ccs" {
  count = var.accept_cpd_license && var.install_ccs ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_ccs.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
  ]
}

resource "null_resource" "install_data_refinery" {
  count = var.accept_cpd_license && var.install_data_refinery ? 1 : 0

  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-data-refinery.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
  ]
}

resource "null_resource" "install_db2u_operator" {
  count = var.accept_cpd_license == "yes" && var.install_db2u_operator ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-db2u-operator.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
  ]
}

resource "null_resource" "install_dmc" {
  count = var.accept_cpd_license == "yes" && var.install_dmc ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-dmc.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
  ]
}

resource "null_resource" "install_db2aaservice" {
  count = var.accept_cpd_license == "yes" && var.install_db2aaservice ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-db2aaservice.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
  ]
}

resource "null_resource" "install_wsl" {
  count = var.accept_cpd_license == "yes" && var.install_wsl ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install_wsl.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
  ]
}

resource "null_resource" "install_aiopenscale" {
  count = var.accept_cpd_license == "yes" && var.install_aiopenscale ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-aiopenscale.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
  ]
}

resource "null_resource" "install_wml" {
  count = var.accept_cpd_license == "yes" && var.install_wml ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-wml.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
  ]
}

resource "null_resource" "install_wkc" {
  count = var.accept_cpd_license == "yes" && var.install_wkc ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-wkc.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
  ]
}

resource "null_resource" "install_dv" {
  count = var.accept_cpd_license == "yes" && var.install_dv ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-dv.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
  ]
}

resource "null_resource" "install_spss" {
  count = var.accept_cpd_license == "yes" && var.install_spss ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-spss.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
  ]
}

resource "null_resource" "install_cde" {
  count = var.accept_cpd_license == "yes" && var.install_cde ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-cde.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
  ]
}

resource "null_resource" "install_spark" {
  count = var.accept_cpd_license == "yes" && var.install_spark ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-spark.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
    null_resource.install_cde,
  ]
}

resource "null_resource" "install_dods" {
  count = var.accept_cpd_license == "yes" && var.install_dods ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-dods.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
    null_resource.install_cde,
    null_resource.install_spark,
  ]
}

resource "null_resource" "install_ca" {
  count = var.accept_cpd_license == "yes" && var.install_ca ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-ca.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
    null_resource.install_cde,
    null_resource.install_spark,
    null_resource.install_dods,
  ]
}

resource "null_resource" "install_ds" {
  count = var.accept_cpd_license == "yes" && var.install_ds ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-ds.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
    null_resource.install_cde,
    null_resource.install_spark,
    null_resource.install_dods,
    null_resource.install_ca,
  ]
}

resource "null_resource" "install_db2oltp" {
  count = var.accept_cpd_license == "yes" && var.install_db2oltp ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-db2oltp.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
    null_resource.install_cde,
    null_resource.install_spark,
    null_resource.install_dods,
    null_resource.install_ca,
    null_resource.install_ds,
  ]
}

resource "null_resource" "install_db2wh" {
  count = var.accept_cpd_license == "yes" && var.install_db2wh ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-db2wh.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
    null_resource.install_cde,
    null_resource.install_spark,
    null_resource.install_dods,
    null_resource.install_ca,
    null_resource.install_ds,
    null_resource.install_db2oltp,
  ]
}

resource "null_resource" "install_big_sql" {
  count = var.accept_cpd_license == "yes" && var.install_big_sql ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      # CLUSTER_NAME = "${var.unique_id}-cluster"
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-big-sql.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_ccs,
    null_resource.install_data_refinery,
    null_resource.install_db2u_operator,
    null_resource.install_dmc,
    null_resource.install_db2aaservice,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
    null_resource.install_cde,
    null_resource.install_spark,
    null_resource.install_dods,
    null_resource.install_ca,
    null_resource.install_ds,
    null_resource.install_db2oltp,
    null_resource.install_db2wh,
  ]
}