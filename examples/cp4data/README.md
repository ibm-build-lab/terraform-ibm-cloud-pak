# Cloud Pak for Data Parameters and Installation Validation

## Cloud Pak Entitlement Key

This Cloud Pak requires an Entitlement Key. It can be retrieved from https://myibm.ibm.com/products-services/containerlibrary.

Edit the `./my_variables.auto.tfvars` file to define the `entitled_registry_user_email` variable and optionally the variable `entitled_registry_key` or save the entitlement key in the file `entitlement.key`. The IBM Cloud user email address is required in the variable `entitled_registry_user_email` to access the IBM Cloud Container Registry (ICR), set the user email address of the account used to generate the Entitlement Key.

For example:

```hcl
entitled_registry_user_email = "john.smith@ibm.com"

# Optionally:
entitled_registry_key        = "< Your Entitled Key here >"
```

**IMPORTANT**: Make sure to not commit the Entitlement Key file or content to the github repository.

## Input Parameters

In addition, the Terraform code requires the following input parameters, for some variables are instructions to get the possible values using `ibmcloud`.

| Name                               | Description                                                                                                                                                                                                                                                                                                                  | Default                     | Required |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `project_name`                     | The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources                                                                                                                                                                                              | `cloud-pack`                | Yes      |
| `owner`                            | Use your user name or team name. The owner is used to label the cluster and other resources                                                                                                                                                                                                                                  | `anonymous`                 | Yes      |
| `environment`                      | The environment name is used to label the cluster and other resources                                                                                                                                                                                                                                                        | `sandbox`                   | No       |
| `region`                           | IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions`                                                                                                                                                                                                                                   | `us-south`                  | No       |
| `resource_group`                   | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`                                                                                                                                                                                                      | `cloud-pak-sandbox`         | No       |
| `cluster_id`                       | If you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned                                                                                                                                                                             |                             | No       |
| `datacenter`                       | On IBM Cloud Classic this is the datacenter or Zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`                                                                                                                                                          | `dal10`                     | No       |
| `private_vlan_number`              | Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is private and the router begins with **bc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again. |                             | No       |
| `public_vlan_number`               | Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is public and the router begins with **fc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again.   |                             | No       |
| `entitled_registry_key`            | Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, copy and paste the key to this variable or save the key to the file `entitlement.key`.                                                                                                                                               |                             | No       |
| `entitled_registry_user_email`     | Email address of the user owner of the Entitled Registry Key                                                                                                                                                                                                                                                                 |                             | Yes      |
| `storage_class_name`               | Storage Class name to use                                                                                                                                                                                                                                                                                                    | `ibmc-file-custom-gold-gid` | No       |
| `install_watson_knowledge_catalog` | Install Watson Knowledge Catalog module. By default it's not installed.                                                                                                                                                                                                                                                      | `false`                     | No       |
| `install_watson_studio`            | Install Watson Studio module. By default it's not installed.                                                                                                                                                                                                                                                                 | `false`                     | No       |
| `install_watson_machine_learning`  | Install Watson Machine Learning module. By default it's not installed.                                                                                                                                                                                                                                                       | `false`                     | No       |
| `install_watson_open_scale`        | Install Watson Open Scale module. By default it's not installed.                                                                                                                                                                                                                                                             | `false`                     | No       |
| `install_data_virtualization`      | Install Data Virtualization module. By default it's not installed.                                                                                                                                                                                                                                                           | `false`                     | No       |
| `install_streams`                  | Install Streams module. By default it's not installed.                                                                                                                                                                                                                                                                       | `false`                     | No       |
| `install_analytics_dashboard`      | Install Analytics Dashboard module. By default it's not installed.                                                                                                                                                                                                                                                           | `false`                     | No       |
| `install_spark`                    | Install Analytics Engine powered by Apache Spark module. By default it's not installed.                                                                                                                                                                                                                                      | `false`                     | No       |
| `install_db2_warehouse`            | Install DB2 Warehouse module. By default it's not installed.                                                                                                                                                                                                                                                                 | `false`                     | No       |
| `install_db2_data_gate`            | Install DB2 Data_Gate module. By default it's not installed.                                                                                                                                                                                                                                                                 | `false`                     | No       |
| `install_rstudio`                  | Install RStudio module. By default it's not installed.                                                                                                                                                                                                                                                                       | `false`                     | No       |
| `install_db2_data_management`      | Install DB2 Data Management module. By default it's not installed.                                                                                                                                                                                                                                                           | `false`                     | No       |

If you are using Schematics directly or the Private Catalog, set the variable `entitled_registry_key` with the content of the Entitlement Key, the file `entitlement.key` is not available.

## Output Parameters

The Terraform code return the following output parameters.

| Name                | Description                                                                                                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_endpoint`  | The URL of the public service endpoint for your cluster                                                                             |
| `cluster_id`        | The unique identifier of the cluster.                                                                                               |
| `cluster_name`      | The cluster name which should be: `{project_name}-{environment}-cluster`                                                            |
| `resource_group`    | Resource group where the OpenShift cluster is created                                                                               |
| `kubeconfig`        | File path to the kubernetes cluster configuration file. Execute `export KUBECONFIG=$(terraform output kubeconfig)` to use `kubectl` |
| `cp4data_endpoint`  | URL of the CP4Data dashboard                                                                                                        |
| `cp4data_user`      | Username to login to the CP4Data dashboard                                                                                          |
| `cp4data_password`  | Password to login to the CP4Data dashboard                                                                                          |
| `cp4data_namespace` | Kubernetes namespace where all the CP4Data objects are installed                                                                    |

## Validations

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

Execute the following commands to validate this cloud pak:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output cp4data_namespace)

# All resources
kubectl get all --namespace $(terraform output cp4data_namespace)
```

Using the following credentials:

```bash
terraform output cp4data_user
terraform output cp4data_password
```

Open the following URL:

```bash
open $(terraform output cp4data_endpoint)
```

## Uninstall

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.

To remove this from Schematics, a user needs to run `./remove_attached.sh` from `cloud-pak-sandboxes/scripts/portworx/`

Example:
```bash
./remove_attached.sh -r us-east -c cluster_name
```

Lastly, delete the resources and workspace from the Schematic.