locals {
  cp4aiops_subscription = file(join("/", [path.module, "files", "aiops-subscription.yaml"]))
  on_vpc_ready = var.on_vpc ? var.portworx_is_ready : 1
  oc_serverless_file              = "${path.module}/files/openshift-serverless.yaml"
  oc_serverless_file_content      = file(local.oc_serverless_file)
  knative_serving_file            = "${path.module}/files/knative-serving.yaml"
  knative_serving_file_content    = file(local.knative_serving_file)
  knative_eventing_file           = "${path.module}/files/knative-eventing.yaml"
  knative_eventing_file_content   = file(local.knative_eventing_file)

}

resource "null_resource" "install_cp4aiops" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1                      = sha1(var.cp4aiops_namespace)
    docker_params_sha1                  = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    cp4aiops_sha1                       = sha1(local.cp4aiops_subscription)
    oc_serverless_file_sha1             = sha1(local.oc_serverless_file_content)
    knative_serving_file_sha1           = sha1(local.knative_serving_file_content)
    knative_eventing_file_sha1          = sha1(local.knative_eventing_file)
  }

  provisioner "local-exec" {
    command     = "./install_cp4aiops.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.cp4aiops_namespace
      ON_VPC                        = var.on_vpc
      IC_API_KEY                    = var.ibmcloud_api_key
      CP4WAIOPS                     = local.cp4aiops_subscription
      ENTITLED_REGISTRY_KEY         = var.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry

      # --- File Assignment ---
      OC_SERVERLESS_FILE    = local.oc_serverless_file
      KNATIVE_SERVING_FILE  = local.knative_serving_file
      KNATIVE_EVENTING_FILE = local.knative_eventing_file
    }
  }

  depends_on = [
    local.on_vpc_ready,
    null_resource.prereqs_checkpoint
  ]
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4aiops
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.cp4aiops_namespace
  }
}
