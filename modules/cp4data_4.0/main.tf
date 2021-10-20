
##############################
# Install Bedrock Zen Operator
#############################


resource "null_resource" "bedrock_zen_operator" {
  count = var.accept_cpd_license ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      ENTITLEMENT_USER = var.entitled_registry_user_email
      ENTITLEMENT_KEY = var.entitled_registry_key
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      IBMCLOUD_APIKEY = var.ibmcloud_api_key
      IBMCLOUD_RG_NAME = var.resource_group_name
      REGION = var.region
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-bedrock-zen-operator.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
  ]
}

resource "null_resource" "install_wsl" {
  count = var.accept_cpd_license && var.install_wsl ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      OP_NAMESPACE = var.operator_namespace
      NAMESPACE = var.cpd_project_name
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-wsl.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
  ]
}

resource "null_resource" "install_aiopenscale" {
  count = var.accept_cpd_license && var.install_aiopenscale ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-aiopenscale.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_wsl,
  ]
}

resource "null_resource" "install_wml" {
  count = var.accept_cpd_license && var.install_wml ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-wml.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
  ]
}

resource "null_resource" "install_wkc" {
  count = var.accept_cpd_license && var.install_wkc ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-wkc.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
  ]
}

resource "null_resource" "install_dv" {
  count = var.accept_cpd_license && var.install_dv ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-dv.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
  ]
}

resource "null_resource" "install_spss" {
  count = var.accept_cpd_license && var.install_spss ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-spss.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
  ]
}

resource "null_resource" "install_cde" {
  count = var.accept_cpd_license && var.install_cde ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-cde.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
    null_resource.install_wsl,
    null_resource.install_aiopenscale,
    null_resource.install_wml,
    null_resource.install_wkc,
    null_resource.install_dv,
    null_resource.install_spss,
  ]
}

resource "null_resource" "install_spark" {
  count = var.accept_cpd_license && var.install_spark ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-spark.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
  count = var.accept_cpd_license && var.install_dods ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-dods.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
  count = var.accept_cpd_license && var.install_ca ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-ca.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
  count = var.accept_cpd_license && var.install_ds ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-ds.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
  count = var.accept_cpd_license && var.install_db2oltp ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-db2oltp.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
  count = var.accept_cpd_license && var.install_db2wh ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-db2wh.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
  count = var.accept_cpd_license && var.install_big_sql ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-big-sql.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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

resource "null_resource" "install_wsruntime" {
  count = var.accept_cpd_license && var.install_wsruntime ? 1 : 0
  
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = var.cluster_id
      KUBECONFIG = var.cluster_config_path
      NAMESPACE = var.cpd_project_name
      OP_NAMESPACE = var.operator_namespace
      ON_VPC = var.on_vpc
    }
    
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./install-wsruntime.sh"
  }
  
  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
    null_resource.install_big_sql,
  ]
}

# Reencrypt route
resource "null_resource" "reencrypt_route" {
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    working_dir = "${path.module}/scripts/"
    interpreter = ["/bin/bash", "-c"]
    command = "./reencrypt_route.sh ${var.cpd_project_name}"
  }

  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
  ]
}


data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    var.portworx_is_ready,
    null_resource.prereqs_checkpoint,
    null_resource.bedrock_zen_operator,
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
    null_resource.install_big_sql,
    null_resource.install_wsruntime,
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.cpd_project_name
  }
}
