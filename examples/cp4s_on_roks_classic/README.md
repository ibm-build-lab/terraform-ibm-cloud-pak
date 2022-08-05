# Example roks_classic_with_cp4s
This example provisions an IBM Cloud Platform Classic Infrastructure OpenShift Cluster and installs the Cloud Pak for Security on it.  To install Cloud Pak for Security, a cluster is needed with at least 5 nodes of size 16x32.

NOTE: An LDAP is required for new instances of CP4S. This is not required for installation but will be required before CP4S can be used. If you do not have an LDAP you can complete the installation however full features will not be available until after LDAP configuration is complete. There is terraform automation available to provision and LDAP here. This link can provide more information here.


## Inputs

| Name                               | Description  | Default                     | Required |
| ---------------------------------- | ----- | --------------------------- | -------- |
| `project_name`                       | The `project_name` is combined with `environment` to name the cluster. The cluster name will be `{project_name}-{environment}` and all the resources will be tagged with `project:{project_name}`|         `cp4s`                    | No       |
| `environment`                      | The `environment` is combined with `project_name` to name the cluster. The cluster name will be `{project_name}-{environment}` and all the resources will be tagged with `env:{environment}`    | `dev`                   | No       |
| `owner`                            | Use your user name or team name. The owner is used to label the cluster and other resources  | `anonymous`                 | No      |
| `region`                           | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`    | `us-south`                  | No       |
| `resource_group`                   | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`     | `Default`         | No       |
| `worker_zone`                       | The datacenter or zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`   | `dal10`                     | No       |
| `workers_count`                       | Number of workers to provision.   | 4                     | No       |
| `worker_pool_flavor`                       | The machine type for your worker node.   | `b3c.16x64`                     | No       |
| `private_vlan`              | Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the VLAN type is private and the router begins with **bc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again. |                             | No       |
| `public_vlan`               | Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the VLAN type is public and the router begins with **fc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again.   |                             | No       |
| `hardware`               | The level of hardware isolation for your worker node.  |             `shared`                | No       |
| `master_service_public_endpoint`               | Enable the public service endpoint to make the master publicly accessible.|             true                | No       |
| `entitlement`               | Create your cluster with existing entitlement.|             true                | No       |
| `force_delete_storage`               | Set to delete persistent storage of cluster when cluster is deprovisioned   |             true                | No       |
| `roks_version`               | The OpenShift version that you want to set up in your cluster. |             true                | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary.   |                             | Yes      |
| `entitled_registry_user_email`     | Email address of the user owner of the Entitled Registry Key   |                             | Yes      |
| `config_dir`     | Path to store cluster config file |       `./.kube/config`                      | No      |
| `namespace`     | Project to install Cloud Pak in |       `cp4i`                      | No      |

If running locally, set the desired values for these variables in the `terraform.tfvars` file.  Here are some examples:

```hcl
region                       = "us-south"
worker_zone                  = "dal12"
resource_group               = "Default"
workers_count                = 5
worker_pool_flavor           = "c3c.16x32"
public_vlan                  = "3048689"
private_vlan                 = "3048687"
force_delete_storage         = true
project_name                 = "cp4s"
environment                  = "test"
owner                        = "anonymous"
roks_version                 = 4.8
entitled_registry_key        = "************************"
entitled_registry_user_email = "johndoe@ibm.com"
```

## Outputs

None

### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify

To verify installation on the cluster, go to the `Installed Operators` tab on the Openshift console. Choose your `cp4s` and click on `IBM Cloud Pak for Security` . Click on the `Threatmanagement` tab. Check the status of the `Threatmgmt`.

### Cleanup

Go into the console and delete the platform navigator from the verify section. Delete all installed operators and lastly delete the project.

Finally, execute: `terraform destroy`.

If running locally, there are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`.