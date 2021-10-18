# Cloud Pak for Business Automation

## Requirements

Make sure all requirements listed [here](../README.md#requirements) are completed.

## Configure Access to IBM Cloud

Make sure access to IBM Cloud is set up.  Go [here](../README.md#configure-access-to-ibm-cloud) for details.

## Cloud Pak Entitlement Key

This Cloud Pak requires an Entitlement Key. It can be retrieved from [here](https://myibm.ibm.com/products-services/containerlibrary).

If running local Terraform client, edit the `./terraform.tfvars` file to define the `entitled_registry_user_email` variable and optionally the variable `entitled_registry_key` or save the entitlement key in the file `entitlement.key`. The IBM Cloud user email address is required in the variable `entitled_registry_user_email` to access the IBM Cloud Container Registry (ICR), set the user email address of the account used to generate the Entitlement Key.

For example:
```hcl
entitled_registry_user_email = "john.smith@ibm.com"

# Optionally:
entitled_registry_key        = "< Your Entitled Key here >"
```

**IMPORTANT**: Make sure to not commit the Entitlement Key file or content to the github repository.

## Provisioning the Sandbox

For instructions to provision the sandbox, go [here](../README.md#provisioning-the-sandbox).

## Input Parameters

Besides the access credentials, the Terraform code requires the following input parameters. For some variables there are instructions to get the possible values using `ibmcloud`.

| Name                           | Description    | Default             | Required |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | -------- |
| `cluster_id`                   | **Optional:** cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned  | No       |
| `on_vpc`                   | Ignored if `cluster_id` is specified. Type of infrastructure to provision. `true`=VPC, `false`=Classic  | `false`                    | Yes       |
| `resource_group`               | Ignored if `cluster_id` is specified. Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`   | `cloud-pak-sandbox` | No       |
| `project_name`                 | Ignored if `cluster_id` is specified. The project name is used to name the cluster with the `environment` name. It's also used to label the cluster and other resources   | `cloud-pack`        | Yes      |
| `owner`                        | Ignored if `cluster_id` is specified. Use your user name or team name. The owner is used to label the cluster and other resources    | `anonymous`         | Yes      |
| `environment`                  | Ignored if `cluster_id` is specified. The environment name is used to name the cluster  | `sandbox`           | No       |
| `region`                       |Region of the cluster. List all available regions with: `ibmcloud is regions`   | `us-south`          | No       |
| `datacenter`                   | **Classic only**: Datacenter or Zone in the region of the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`   | `dal10`             | No       |
| `private_vlan_number`          | **Classic only**: Ignored if `cluster_id` is specified. Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the VLAN type is private and the router begins with **bc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone. A VLAN will be provisioned. |                     | No       |
| `public_vlan_number`           | **Classic only**: Ignored if `cluster_id` is specified. Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the VLAN type is public and the router begins with **fc**. Use the ID or Number. This value may be empty if there isn't an existing VLAN in the Zone. A VLAN will be provisioned.   |                     | No       |
| `flavors`        | Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic it is only possible to have one worker group, so only list one flavor, example `["b3c.16x64"]`. Example on VPC, `["b2x.16x64", "cx2.4x8"] or ["mx2.4x32"]`   | `["b3c.16x64"]`                  | No       |
| `vpc_zone_names`                   | **VPC Only**: Ignored if `cluster_id` is specified. Zones in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`   | `us-south-1`             | No       |
| `entitled_registry_key`        | Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, copy and paste the key to this variable or save the key to the file `entitlement.key`.  |                     | No       |
| `entitled_registry_user_email` | Email address of the user owner of the Entitled Registry Key   |                     | Yes      |

If you are using Schematics directly or the Private Catalog, set the variable `entitled_registry_key` with the content of the Entitlement Key, the file `entitlement.key` is not available.

## Output Parameters

The Terraform code return the following output parameters.

| Name               | Description                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_endpoint` | The URL of the public service endpoint for your cluster                                                                             |
| `cluster_id`       | The unique identifier of the cluster.                                                                                               |
| `cluster_name`     | The cluster name which should be: `{project_name}-{environment}-cluster`                                                            |
| `resource_group`   | Resource group where the OpenShift cluster is created                                                                               |
| `kubeconfig`       | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl` |
| `cp4ba_endpoint`  | URL of the CP4BA dashboard                                                                                                         |
| `cp4ba_user`      | Username to login to the CP4BA dashboard                                                                                           |
| `cp4ba_password`  | Password to login to the CP4BA dashboard                                                                                           |
| `cp4ba_namespace` | Kubernetes namespace where all the CP4BA objects are installed                                                                     |

## Validation

If you have not setup `kubectl` to access the cluster, execute:

```bash
# If created with Terraform:
ibmcloud ks cluster config --cluster $(terraform output cluster_id)

# If created with Schematics:
ibmcloud ks cluster config --cluster $(ibmcloud schematics workspace output --id $WORKSPACE_ID --json | jq -r '.[].output_values[].cluster_id.value')

# If created with IBM Cloud CLI:
ibmcloud ks cluster config --cluster $CLUSTER_NAME
```

Verify the cluster is up and running with these commands:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

Execute the following commands to validate this Cloud Pak:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output cp4ba_namespace)

# All resources
kubectl get all --namespace $(terraform output cp4ba_namespace)
```

Using the following credentials:

```bash
terraform output cp4ba_user
terraform output cp4ba_password
```

Open the following URL:

```bash
open "http://$(terraform output cp4ba
_endpoint)"
```

## Uninstall

To uninstall CP4BA and its dependencies from a cluster, execute the following commands:

```bash
kubectl get ICP4ACluster
kubectl get subscription ibm-common-service-operator -n openshift-operators
kubectl get subscription ibm-common-service-operator -n opencloud-operators
kubectl delete namespace cp4ba
```

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
