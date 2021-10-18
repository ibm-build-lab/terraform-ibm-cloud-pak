resource "aws_kms_key" "px_key" {
  description = "Key used to encrypt Portworx PVCs"
}

resource "null_resource" "create_workspace" {
  provisioner "local-exec" {
    command = <<EOF
test -e ${local.installer_workspace} || mkdir -p ${local.installer_workspace}
EOF
  }
}

resource "local_file" "portworx_operator_yaml" {
  content  = data.template_file.portworx_operator.rendered
  filename = "${local.installer_workspace}/portworx_operator.yaml"
}

resource "local_file" "storage_classes_yaml" {
  content  = data.template_file.storage_classes.rendered
  filename = "${local.installer_workspace}/storage_classes.yaml"
}

resource "local_file" "portworx_storagecluster_yaml" {
  content  = data.template_file.portworx_storagecluster.rendered
  filename = "${local.installer_workspace}/portworx_storagecluster.yaml"
}


# resource "null_resource" "login_cluster" {
#   triggers = {
#     openshift_api       = var.openshift_api
#     openshift_username  = var.openshift_username
#     openshift_password  = var.openshift_password
#     openshift_token     = var.openshift_token
#     login_cmd = var.login_cmd
#   }
#   provisioner "local-exec" {
#     command = <<EOF
# ${self.triggers.login_cmd} --insecure-skip-tls-verify || oc login ${self.triggers.openshift_api} -u '${self.triggers.openshift_username}' -p '${self.triggers.openshift_password}' --insecure-skip-tls-verify=true || oc login --server='${self.triggers.openshift_api}' --token='${self.triggers.openshift_token}'
# EOF
#   }
# }

resource "null_resource" "install_portworx" {
  triggers = {
    installer_workspace = local.installer_workspace
    region              = var.region
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    when        = create
    command     = <<EOF
pwd
chmod +x portworx-prereq.sh
bash portworx-prereq.sh ${self.triggers.region}
oc create -f ${self.triggers.installer_workspace}/portworx_operator.yaml
echo "Sleeping for 5mins"
sleep 300
echo "Deploying StorageCluster"
oc create -f ${self.triggers.installer_workspace}/portworx_storagecluster.yaml
sleep 300
echo "Create storage classes"
oc create -f ${self.triggers.installer_workspace}/storage_classes.yaml
EOF
  }

  depends_on = [
    local_file.portworx_operator_yaml,
    local_file.storage_classes_yaml,
    local_file.portworx_storagecluster_yaml
  ]
}

resource "null_resource" "enable_portworx_encryption" {
  count = var.portworx_enterprise.enable && var.portworx_enterprise.enable_encryption ? 1 : 0
  triggers = {
    installer_workspace = local.installer_workspace
    region              = var.region
  }
  provisioner "local-exec" {
    when    = create
    command = <<EOF
echo "Enabling encryption"
PX_POD=$(oc get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
oc exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl secrets aws login
EOF
  }
  depends_on = [
    null_resource.install_portworx,
  ]
}

locals {
  rootpath            = abspath(path.root)
  installer_workspace = "${local.rootpath}/installer-files"
  px_cluster_id       = var.portworx_essentials.enable ? var.portworx_essentials.cluster_id : var.portworx_enterprise.cluster_id
  priv_image_registry = "image-registry.openshift-image-registry.svc:5000/kube-system"
  secret_provider     = var.portworx_enterprise.enable && var.portworx_enterprise.enable_encryption ? "aws-kms" : "k8s"
  px_workspace        = "${local.installer_workspace}/ibm-px"
}
