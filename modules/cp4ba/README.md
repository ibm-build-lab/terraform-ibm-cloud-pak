# Terraform Module to install Cloud Pak for Business Automation

This Terraform Module installs **Cloud Pak for Business Automation** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4ba`

## Set up access to IBM Cloud

If executing these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform script define the `ibm` provisioner block with the `version`.

```hcl
provider "ibm" {
  version          = "~> 1.12"
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks) for the code to add to your Terraform script. The recommended size for an OpenShift 4.5+ cluster on IBM Cloud Classic contains `4` workers of flavor `b3c.16x64`, however read the [Cloud Pak for Automation documentation](https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation) to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

Add the following code to get the OpenShift cluster (new or existing) configuration:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = "./kube/config"     // Create this directory in advance
  admin             = false
  network           = false
}
```

**NOTE**: Create the `./kube/config` directory if it doesn't exist.

Input:

- `cluster_name_id`: either the cluster name or ID.

- `ibm_resource_group`:  resource group where the cluster is running

Output:

`ibm_container_cluster_config` used as input for the `cp4ba` module

### Provisioning the CP4BA Module

Use a `module` block assigning the `source` parameter to the location of this module `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4ba`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Automation.

```hcl
module "cp4ba" {
  source = "../../modules/cp4ba"
  enable = true

  # ---- Cluster ----
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  # ---- Cloud Pak ----
  cp4ba_project_name      = "cp4ba"
  entitled_registry_user  = var.entitled_registry_user
  entitlement_key         = var.entitlement_key

  # ----- DB2 Settings -----
  db2_host_name           = var.db2_host_name
  db2_host_port           = var.db2_host_port
  db2_admin               = var.db2_admin
  db2_user                = var.db2_user
  db2_password            = var.db2_password

  # ----- LDAP Settings -----
  ldap_admin              = var.ldap_admin
  ldap_password           = var.ldap_password
  ldap_host_ip            = var.ldap_host_ip
}
```

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled   | `true`                      | No       |
| `cluster_config_path`              | Path to the Kubernetes configuration file to access your cluster | `./.kube/config`                      | No       |
| `cp4ba_project_name`               | Namespace to install for Cloud Pak for Integration | `cp4ba`                      | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `db2_host_name`                    | DB2 Host Name           |                             | Yes      |   
| `db2_host_port`                    | DB2 Host Port           |                             | Yes      |   
| `ldap_admin`                       | LDAP Host IP           |                             | Yes      |   
| `ldap_password`                    | LDAP Password           |                             | Yes      |   
| `ldap_host_ip`                    | LDAP Host IP           |                             | Yes      | 

**NOTE** The boolean input parameter `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Business Automation Terraform example](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/examples/cp4ba).

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Cloud Pak Console

Check to make sure that the icp4ba cartridge in the IBM Automation Foundation Core is ready. For more information about IBM Automation Foundation, see [What is IBM Automation foundation](https://www.ibm.com/support/knowledgecenter/en/cloudpaks_start/cloud-paks/about/overview-cp.html)?

To view the status of the `icp4ba` cartridge in the OCP Admin console, click **Operators > Installed Operators > IBM Automation Foundation Core**. Click the Cartridge tab, click `icp4ba`, and then scroll to the Conditions section.

When the deployment is successful, a ConfigMap is created in the CP4BA namespace (project) to provide the cluster-specific details to access the services and applications. The ConfigMap name is prefixed with the deployment name (default is icp4adeploy). You can search for the routes with a filter on `cp4ba-access-info`.

The contents of the ConfigMap depends on the components that are included. Each component has one or more URLs, and if needed a username and password. Each component has one or more URLs.

```
<component1> URL: <RouteUrlToAccessComponent1>  
<component2> URL: <RouteUrlToAccessComponent2> 
```

You can find the URL for the Zen UI by clicking **Network > Routes** and looking for the name cpd, or by running the following command.

```console
oc get route |grep "^cpd"
  ```
  
You can get the default username by running the following command:

```console
oc -n ibm-common-services get secret platform-auth-idp-credentials \
   -o jsonpath='{.data.admin_username}' | base64 -d && echo
```
You get the password by running the following command:
```console

oc -n ibm-common-services get secret platform-auth-idp-credentials \
   -o jsonpath='{.data.admin_password}' | base64 -d
```
## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```
