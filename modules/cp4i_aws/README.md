# Terraform Module to install Cloud Pak for Integration

This Terraform Module installs **Cloud Pak for Integration** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/cp4i_aws`

- [Terraform Module to install Cloud Pak for Integration](#terraform-module-to-install-cloud-pak-for-integration)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Setting up Portworx](#setting-up-portworx)
    - [Using the CP4I Module](#using-the-cp4i-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Clean up](#clean-up)

## Provisioning this module in a Terraform Script

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned on AWS.

**NOTE**: Create the `./kube/config` directory if it doesn't exist.

### Setting up Portworx

NOTE: This module requires Portworx on AWS. To see how to add Portworx, please check this [link](https://github.com/ibm-build-labs/terraform-ibm-cloud-pak/tree/main/modulesportworx_aws)

### Using the CP4I Module

Use a `module` block assigning the `source` parameter to the location of this module `github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/cp4i`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Integration.

```hcl
module "cp4i" {
  source          = "github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/cp4i_aws"
  enable          = true

  // ROKS cluster parameters:
  cluster_config_path = var.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
}
```

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled  | `true`                      | No       |
| `storageclass`                           | Storage class to use.  For VPC on AWS, set to `portworx-shared-gp3` or RWX similar Portworx storage class and make sure Portworx is set up on the cluster                                                | `ibmc-file-gold-gid`                      | No       |
| `namespace`                           | Namespace to install for Cloud Pak for Integration | `cp4i`                      | No       |
| `cluster_config_path`                           | Path to the Kubernetes configuration file to access your cluster | `./.kube/config`                      | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key |                             | Yes      |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Integration Terraform script](https://github.com/ibm-build-labs/cloud-pak-sandboxes/tree/master/terraform/cp4int).

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```

## Known Issues

If the installation takes longer than an hour to install or it hangs:

- Please check the namespace used for installation and look at the `IBM-MQ` operator to ensure it's properly installed. If it isn't, uninstall the operator and check the operator hub for the latest up-to-date version.
- If the `zen-metastoredb-0/1/2` are in a `0/1` state, please delete the pod(s) and let it restart.
