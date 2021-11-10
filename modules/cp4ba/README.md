# Terraform Module to install Cloud Pak for Business Automation

This Terraform Module installs **Cloud Pak for BUsiness Automation** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4ba`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

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

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script. The recommended size for an OpenShift 4.7 cluster on IBM Cloud Classic contains `5` workers of flavor `b3c.16x64`, however read the [Cloud Pak for Business Automation documentation](https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation) to confirm these parameters.

Add the following code to get the OpenShift cluster (new or existing) configuration:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ./.kube/config"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = "./.kube/config"
}
```
Input:

- `cluster_name_id`: either the cluster name or ID.

- `ibm_resource_group`:  resource group where the cluster is running

Output:

`ibm_container_cluster_config` used as input for the `cp4ba` module

### Using the CP4BA Module

Use a `module` block assigning the `source` parameter to the location of this module `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4ba`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Business Automation.

```hcl
module "cp4ba" {
  source = "../../modules/cp4ba"
  enable = true

  # ---- Cluster settings ----
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain = var.ingress_subdomain

  # ---- Cloud Pak settings ----
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
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled  | `true`                      | No       |
| `cluster_config_path`              | Path to the Kubernetes configuration file to access your cluster | `./.kube/config`                      | No       |
| `ingress_subdomain`                | Run the command `ibmcloud ks cluster get -c <cluster_name_or_id>` to get the Ingress Subdomain value |  | No       |
| `cp4ba_project_name`               | Namespace to install for Cloud Pak for Integration | `cp4ba`                      | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key |  | Yes      |
| `ldap_admin`     | LDAP Admin user name | `cn=root`  | Yes      |
| `ldap_password`     | LDAP Admin password | `Passw0rd` | Yes      |
| `ldap_host_ip`     | LDAP server IP address |  | Yes      |
| `db2_host_name`     | Host for DB2 instance |  | Yes      |
| `db2_host_port`     | Port for DB2 instance |  | Yes      |
| `db2_admin`     | Admin user name defined in associated LDAP| `cpadmin` | Yes      |
| `db2_user`     | User name defined in associated LDAP | `db2inst1` | Yes      |
| `db2_password`     | Password defined in associated LDAP | `passw0rd` | Yes      |

For an example of how to put all this together, refer to our [Cloud Pak for Business Automation Terraform example](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4ba).

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```


## Output Parameters

The Terraform code return the following output parameters.

| Name               | Description                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cp4ba_endpoint`  | URL of the CP4BA dashboard                                                                                                         |
| `cp4ba_user`      | Username to login to the CP4BA dashboard                                                                                           |
| `cp4ba_password`  | Password to login to the CP4BA dashboard                                                                                           |

## Validation

### Namespace
```
kubectl get namespaces cp4ba
```
### All resources
```
kubectl get all --namespace cp4ba
```
### Get route
```
oc get route |grep "^cpd"
```

Using the following credentials:

```bash
terraform output cp4ba_user
terraform output cp4ba_password
```

Log into the 
## Uninstall

To uninstall CP4BA and its dependencies from a cluster, execute the following commands:

```bash
kubectl get ICP4ACluster
kubectl get subscription ibm-common-service-operator -n openshift-operators
kubectl get subscription ibm-common-service-operator -n opencloud-operators
kubectl delete namespace cp4ba
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
