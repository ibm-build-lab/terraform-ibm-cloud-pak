# Terraform Module to install Portworx on a VPC cluster

### NOTE: This module has been deprecated and is no longer supported.


This Terraform Module installs the **Portworx Service** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/portworx/modules/portworx_ibm`

**NOTE:** an OpenShift VPC cluster is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

## Provisioning the Portworx Module
Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [input variables](#inputs).
```
module "portworx" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/portworx/modules/portworx_ibm"
  enable = true

  ibmcloud_api_key = var.ibmcloud_api_key

  // Cluster parameters
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  worker_nodes     = var.worker_nodes // Number of workers

  // Storage parameters
  install_storage  = true
  storage_capacity = var.storage_capacity // In GBs
  storage_iops     = var.storage_iops     // Must be a number, it will not be used unless a storage_profile is set to a custom profile
  storage_profile  = var.storage_profile

  // Portworx parameters
  resource_group_name = var.resource_group_name
  region              = var.region
  cluster_id          = var.cluster_id
  unique_id           = var.unique_id

  // These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
  // You may override these for additional security.
  create_external_etcd = var.create_external_etcd
  etcd_username        = var.etcd_username
  etcd_password        = var.etcd_password
  // Defaulted.  Don't change
  etcd_secret_name = "px-etcd-certs"
}
```
For an example on how to provision and execute this module go [here](./example).

## Inputs

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                       | If set to `false` does not install Portworx on the given cluster. Enabled by default | `true`  | Yes       |
| `ibmcloud_api_key`             | This requires an ibmcloud api key found here: `https://cloud.ibm.com/iam/apikeys`    |         | Yes       |
| `kube_config_path`             | This is the path to the kube config                                          |  `.kube/config` | Yes       |
| `worker_nodes`                 | Number of worker nodes in the cluster                                        |                 | Yes       |
| `install_storage`              | If set to `false` does not install storage and attach the volumes to the worker nodes. Enabled by default  |  `true` | Yes      |
| `storage_capacity`             | Sets the capacity of the volume in GBs. |   `200`    | Yes      |
| `storage_iops`                 | Sets the number of iops for a custom class. *Note* This is used only if a user provides a custom `storage_profile` |   `10`    | Yes      |
| `storage_profile`              | The is the storage profile used for creating storage. If this is set to a custom profile, you must update the `storage_iops` |   `10iops-tier`    | Yes      |
| `resource_group_name`          | The resource group name where the cluster is housed                                  |         | Yes      |
| `region`                       | The region that resources will be provisioned in. Ex: `"us-east"` `"us-south"` etc.  |         | Yes      |
| `cluster_id`                   | The name of the cluster created |  | Yes       |
| `unique_id`                    | The id of the portworx-service  |  | Yes       |
| `create_external_etcd`         | Set this value to `true` or `false` to create an external etcd | `false` | Yes |
| `etcd_username`                | Username needed for etcd                         | `portworxuser`     | yes |
| `etcd_password`                | Password needed for etcd                         | `portworxpassword` | Yes |
| `etcd_secret_name`             | Etcd secret name, do not change it from default  | `px-etcd-certs`    | Yes |


## Clean up

To remove Portworx and Storage from a cluster, execute the following command:

Run in the cluster:
```bash
curl -fsL https://install.portworx.com/px-wipe | bash
```

Next, run the following script from the command line. This will removes the attachments of the storage from the cluster.

__NOTE:__ Make sure to update the `UNIQUE_ID` in `/cleanup/remove_attached.sh` if it's changed from its default value. 

If the volume needs to be deleted, uncomment the commented out section at the bottom of the script.
```bash
./cleanup/remove_attached.sh -c [CLUSTER NAME OR ID] -r [REGION]
```

Finally run the command below from command line:
```bash
terraform destroy
```



