# Terraform Module to install Cloud Pak for Watson AIOps

This Terraform Module installs **Cloud Pak for Watson AIOps** on OCS on AWS.

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4aiops_aws`

- [Terraform Module to install Cloud Pak for Watson AIOps](#terraform-module-to-install-cloud-pak-for-aiops)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Installing the CP4AIOps Module](#installing-the-cp4aiops-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Clean up](#clean-up)
  - [Troubleshooting](#troubleshooting)
  
### Installing the CP4AIOPS Module

__NOTE:__ 
- You must have an OpenShift cluster created that meets minimum specs for CP4AIOps. 
- You need to have Portworx on the OpenShift cluster. More info can be found [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/portworx_aws)

Use a `module` block assigning `source` to `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4aiops_aws`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Watson AIOps.

```hcl
module "cp4aiops" {
  source          = "./.."
  enable          = var.enable

  // ROKS cluster parameters:
  cluster_config_path = var.cluster_config_path
  on_vpc              = var.on_vpc

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  namespace = var.namespace
}
```

- 

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                                        | `true`                      | No       |
| `on_vpc`                           | If set to `false`, it will set the install do classic ROKS. By default it's disabled                                                                                                                        | `false`                      | No       |
| `cluster_config_path`                | The path of the kube config                                                                                                                                                                                 |       `./.kube/config`              | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `namespace`          | Name of the namespace aiops will be located | `cp4aiops` | no       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.


## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

1. Create a `.kube` directory in the location you want to run this script.

2. Run `touch .kube/config && KUBECONFIG=.kube/config oc login --token=******** --server=*******`

3. Finaly:
```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`

To get default login id:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d && echo
```

To get default Password:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```
