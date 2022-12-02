# Example to provision CP4Data Terraform module on a ROKS cluster

**NOTE:** an OpenShift cluster with at least 4 nodes of size 16x64 is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
customizing these values in the `terraform.tfvars` file:

```hcl
resource_group_name = "Default"
ibmcloud_api_key = "*******************"

// ROKS cluster parameters:
cluster_id          = "******************"
region              = "us-south"
on_vpc              = true

// Prereqs
//worker_node_flavor = "b3c.16x64"        // For Classic
worker_node_flavor = "bx2.16x64"          // For VPC

// Entitled Registry parameters:
entitled_registry_key        = "******************"

// CP4D License Acceptance
accept_cpd_license = true
cpd_project_name = "cp4d"

storage_option = "odf"          // odf | portwork | nfs

// Parameters to install submodules
install_wsl         = false
install_aiopenscale = false
install_wml         = false
install_wkc         = false
install_dv          = false
install_spss        = false
install_cde         = false
install_spark       = false
install_dods        = false
install_ca          = false
install_ds          = false
install_db2oltp     = false
install_db2wh       = false
install_big_sql     = false
install_wsruntime   = false
```

These parameters are:
- `ibmcloud_api_key`: IBM Cloud account API Key
- `cluster_id`: ID of the cluster to install on 
- `region`: Region that the cluster is provisioned in
- `resource_group_name`: Resource group that the cluster is provisioned in
- `on_vpc`: If set to `true`, it will set the install for a VPC cluster. By default it's set to `false`
- `worker_node_flavor`: Flavor of the cluster worker nodes.  Needed for storage determination.
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `accept_cpd_license`: If set to `true`, you accept all cpd license agreements including additional modules installed. By default, it's `false`
- `cpd_project_name`: Namespace to install CP4D in
- `storage_option`: Define the storage option. Defaults to `portworx`. (odf, nfs, portworx)
- `install_wsl`:  Install Watson Studio module. By default it's not installed. 
- `install_aiopenscale`: Install  Watson AI OpenScale module. By default it's not installed. 
- `install_wml`: Install Watson Machine Learning module. By default it's not installed.
- `install_wkc`: Install Watson Knowledge Catalog module. By default it's not installed.
- `install_dv`: Install Data Virtualization module. By default it's not installed.
- `install_spss`: Install SPSS Modeler module. By default it's not installed. 
- `install_cde`: Install Cognos Dashboard Engine module. By default it's not installed.  
- `install_spark`: Install Analytics Engine powered by Apache Spark module. By default it's not installed.
- `install_dods`: Install Decision Optimization module. By default it's not installed. 
- `install_ca`: Install Cognos Analytics module. By default it's not installed. 
- `install_ds`: Install DataStage module. By default it's not installed.
- `install_db2oltp`: Install Db2oltp module. By default it's not installed.
- `install_db2wh`: Install Db2 Warehouse module. By default it's not installed.         
- `install_big_sql`: Install Db2 Big SQL module. By default it's not installed.
- `install_wsruntime`: Install Jupyter Python 3.7 Runtime Addon. By default it's not installed.
- `cluster_config_path`: Directory to place kube config. For Schematic, it's recommended to use `/tmp/.schematics/.kube/config`                                

### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify

To verify installation on the Kubernetes cluster go to the console and go to the `Installed Operators` tab. Click on IBM Cloud Pak for Data and click on `Cloud Pak for Data Service` tab. Finally check the status of the lite-cpdservice.


## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
oc get route -n ${NAMESPACE} cpd -o jsonpath='{.spec.host}' && echo
```

To get default login id:

```bash
username = "admin"
```

To get default Password:

```bash
oc -n ${NAMESPACE} get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d && echo
```

## Clean up

Go into the console and delete `cpd_project_name` and `cpd-meta-ops` projects.

Under `kube-system` daemon-sets, remove `norootsquash` and `kernel-optimization`.

Under `openshift-image-registry` routes, remove `image-registry`.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```

## Troubleshooting

- Once `module.cp4data.null_resource.bedrock_zen_operator` completes. You can check the logs to find out more information about the installation of Cloud Pak for Data.

```bash
cpd-meta-operator: oc -n cpd-meta-ops logs -f deploy/ibm-cp-data-operator

cpd-install-operator: oc -n cpd-tenant logs -f deploy/cpd-install-operator
```
