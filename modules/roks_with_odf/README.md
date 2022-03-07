# IBM Red Hat OpenShift Managed Cluster Parameters and Installation

## Set up

If running using your local Terraform Client, copy the appropriate `terraform.tfvars.classic` or `terraform.tfvars.vpc` to `terraform.tfvars` and ensure your values are set properly.  
 
## Input Parameters

The Terraform script requires the following list of input variables. Here are some instructions to set their values for Terraform and how to get their values from IBM Cloud. Pay attention to the parameters required for **Classic** vs **VPC**.

| Name | Description  | Default | Required |
| - | - | - | - |
| `cluster_id`          | Name or Id of existing cluster if only installing ODF. If left blank, a new Openshift cluster will be provisioned |              | No       |
| `entitlement`          | Ignored if `cluster_id` is specified. Enter `cloud_pak` if using a Cloud Pak entitlement. Leave blank if using OCP entitlement |              | No       |
| `on_vpc`               | Ignored if `cluster_id` is specified. If `true` provision the cluster on IBM Cloud VPC Gen 2, otherwise provision on IBM Cloud Classic  | `true`           | No       |
| `region`               | Ignored if `cluster_id` is specified. IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions` | `us-south`           | No       |
| `resource_group`       | Ignored if `cluster_id` is specified. Resource Group used to host the cluster. List all available resource groups with: `ibmcloud resource groups`   | `default`        | No       |
| `roks_version`         | Ignored if `cluster_id` is specified. OpenShift version to install. List all available versions: `ibmcloud ks versions`. There is no need to include the suffix `_OpenShift`. The module will append it to install the specified version of OpenShift.  | `4.7`            | No       |
| `project_name`         | Ignored if `cluster_id` is specified. Used to name new cluster along with the `environment` name, like this: `{project_name}-{environment}-cluster`<br />It's also used to label the cluster and other resources  |  | Yes      |
| `owner`                | Optional: User name or team name. Used to label the cluster and other resources   |  | Yes      |
| `environment`          | Ignored if `cluster_id` is specified. Used to name the cluster with the `project` name, like this: `{project_name}-{environment}-cluster` | `dev`            | No       |
| `datacenter`           | **IBM Cloud Classic** only (`on_vpc` = `false`). Ignored if `cluster_id` is specified. This is the Datacenter or Zone in the Region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`    | `dal10`          | No       |
| `private_vlan_number`  | **IBM Cloud Classic** only. (`on_vpc` = `false`). Ignored if `cluster_id` is specified. Private VLAN assigned to your zone. Make it an empty string to select a private unnamed VLAN or to create new VLAN if there isn't one (i.e. this is the first cluster in the zone). To list available VLANs in the zone: `ibmcloud ks vlan ls --zone <datacenter>`. Make sure the the VLAN type is `private` and the router begins with `bc`. Use the `ID` or `Number` |                  | No       |
| `public_vlan_number`   | **IBM Cloud Classic** only (`on_vpc` = `false`). Ignored if `cluster_id` is specified. Public VLAN assigned to your zone. Set to an empty string to select a public unnamed VLAN or to create a new VLAN if there aren't any (i.e. this is the first cluster in the zone). List available VLANs in the zone: `ibmcloud ks vlan ls --zone <datacenter>`. Make sure the the VLAN type is `public` and the router begins with `fc`. Use the `ID` or `Number`    |                  | No       |
| `vpc_zone_names`       | **IBM Cloud VPC Gen 2** only (`on_vpc` = `true`). Ignored if `cluster_id` is specified. Array with the sub-zones in the region to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example: `["us-south-1", "us-south-2", "us-south-3"]`   | `["us-south-1"]` | No       |
| `flavors`              | Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers.  List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic it is only possible to have one worker group, so only list one flavor, i.e. `["b3c.16x64"]`. Example on VPC `["mx2.4x32", "mx2.8x64", "cx2.4x8"]` or `["mx2.4x32"]`  | `["mx2.4x32"]`   | No       |
| `workers_count`        | Ignored if `cluster_id` is specified. Array with the amount of workers on each workers group. On Classic it's only possible to have one workers group, so only the first number in the list is taken for the cluster size. Example: `[1, 3, 5]` or `[2]`   | `[2]`            | Yes       |
| `force_delete_storage` | Ignored if `cluster_id` is specified. If set to `true`, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is `false`.                                                             | `false`          | Yes       |
| `is_enable`               | Install ODF on cluster  | false           | No       |
| `ibmcloud_api_key`               | Ignored if Portworx is not enabled: IBMCloud API Key for the account the resources will be provisioned on. This is need for Portworx. Go here to create an ibmcloud_api_key: https://cloud.ibm.com/iam/apikeys  | ""           | No       |


## Output Parameters

The module returns the following output variables:

| Name       | Description                                             |
| ---------- | ------------------------------------------------------- |
| `endpoint` | The URL of the public service endpoint for your cluster |
| `id`       | The unique identifier of the cluster.                   |
| `name`     | The name of the cluster                                 |
| `config_file_path` | Provides the config file path of the cluster |
| `cluster_config`   | Provides the kube config of the cluster |

## Validation

If you use the cluster from other terraform code there may be no need to download the kubeconfig file. However, if you plan to use the cluster from the CLI (i.e. `kubectl`) or other application then it's recommended to download it to some directory.

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud ks cluster config -cluster $(terraform output cluster_id)
kubectl cluster-info
```

<b>For ODF:</b>

If you have not setup `kubectl` to access the cluster, execute:

```bash
# If created with Terraform:
ibmcloud ks cluster config --cluster $(terraform output cluster_id)

# If created with Schematics:
ibmcloud ks cluster config --cluster $(ibmcloud schematics workspace output --id $WORKSPACE_ID --json | jq -r '.[].output_values[].cluster_id.value')

# If created with IBM Cloud CLI:
ibmcloud ks cluster config --cluster $CLUSTER_NAME
```

Verify the cluster is up and running executing these commands:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

Execute the following commands to validate this Cloud Pak:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info
```

For more information on Portworx Validation, go [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/portworx/testing#3-verify).

## Clean up

When the cluster is no longer needed, run `terraform destroy` if this was created using your local Terraform client with `terraform apply`. 

If this cluster was created using `schematics`, just delete the schematics workspace and specify to delete all created resources.

<b>For ODF:</b>

To uninstall ODF and its dependencies from a cluster, execute the following commands:

While logged into the cluster

```bash
terraform destroy -target null_resource.enable_odf
```
This will disable the ODF on the cluster

Once this completes, execute: `terraform destroy` if this was create locally using Terraform or remove the Schematic's workspace.
