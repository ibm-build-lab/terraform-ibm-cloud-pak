# Example cp4i_on_roks_classic
This example provisions an IBM Cloud Platform Classic Infrastructure OpenShift Cluster and installs the Cloud Pak for Integration on it.  To install Cloud Pak for Integration, a cluster is needed with at least 4 nodes of size 16x64.

## Inputs

| Name                               | Description  | Default                     | Required |
| ---------------------------------- | ----- | --------------------------- | -------- |
| `project_name`                       | The `project_name` is combined with `environment` to name the cluster. The cluster name will be `{project_name}-{environment}` and all the resources will be tagged with `project:{project_name}`|         `cp4i`                    | No       |
| `environment`                      | The `environment` is combined with `project_name` to name the cluster. The cluster name will be `{project_name}-{environment}` and all the resources will be tagged with `env:{environment}`    | `dev`                   | No       |
| `owner`                            | Use your user name or team name. The owner is used to label the cluster and other resources  | `anonymous`                 | No      |
| `region`                           | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`    | `us-south`                  | No       |
| `resource_group`                   | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`     | `Default`         | No       |
| `worker_zone`                       | The datacenter or zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`   | `dal10`                     | No       |
| `workers_count`                       | Number of workers to provision.   | 4                     | No       |
| `worker_pool_flavor`                       | The machine type for your worker node.   | `b3c.16x64`                     | No       |
| `private_vlan`              | Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud target -g <resource_group>; ibmcloud ks vlan ls --zone`. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again. |                             | No       |
| `public_vlan`               | Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud target -g <resource_group>; ibmcloud ks vlan ls --zone`. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again.   |                             | No       |
| `hardware`               | The level of hardware isolation for your worker node.  |             `shared`                | No       |
| `master_service_public_endpoint`               | Enable the public service endpoint to make the master publicly accessible.|             true                | No       |
| `entitlement`               | Create your cluster with existing entitlement.|             true                | No       |
| `force_delete_storage`               | Set to delete persistent storage of cluster when cluster is deprovisioned   |             true                | No       |
| `roks_version`               | The OpenShift version that you want to set up in your cluster. |             true                | No       |
| `storage_class`                   | Storage class to be used: Defaulted to `ibmc-file-gold-gid` for Classic Infrastructure. If using a VPC cluster, set to `portworx-rwx-gp3-sc` and make sure Portworx is set up on cluster  | `ibmc-file-gold-gid`         | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary.   |                             | Yes      |
| `entitled_registry_user_email`     | Email address of the user owner of the Entitled Registry Key   |                             | Yes      |
| `config_dir`     | Path to store cluster config file |       `./.kube/config`                      | No      |
| `namespace`     | Project to install Cloud Pak in |       `cp4i`                      | No      |

If running locally, set the desired values for these variables in the `terraform.tfvars` file.  Here are some examples:

```hcl
region                       = "ca-tor"
worker_zone                  = "tor01"
resource_group               = "Default"
workers_count                = 4
worker_pool_flavor           = "b3c.16x64"
public_vlan                  = "3048689"
private_vlan                 = "3048687"
force_delete_storage         = true
project_name                 = "cp4i"
environment                  = "test"
owner                        = "anonymous"
roks_version                 = 4.7
entitled_registry_key        = "************************"
entitled_registry_user_email = "johndoe@ibm.com"
```

## Outputs

| Name                               | Description |
| ---------------------------------- | -----
| `url`                       | Public URL to get to Cloud Pak for Integration Dashboard
| `user`                   | Admin User Id for dashboard
| `password`                   | Password for dashboard.  Be sure to reset after initial log in

### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify

To verify installation on the cluster, go to the `Installed Operators` tab on the Openshift console. Choose your `namespace` and click on `IBM Cloud Pak for Integration Platform Navigator 4.2.0 provided by IBM` . Click on the `Platform Navigator` tab. Check the status of the `cp4i-navigator`.

### Cleanup

Go into the console and delete the platform navigator from the verify section. Delete all installed operators and lastly delete the project.

Finally, execute: `terraform destroy`.

If running locally, there are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`.
