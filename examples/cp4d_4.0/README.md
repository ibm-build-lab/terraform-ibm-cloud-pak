# Example to provision CP4Data Terraform module

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
customizing these values in the `terraform.tfvars` file:

```hcl
resource_group_name = "Default"

// ROKS cluster parameters:
cluster_id          = "******************"
region                = "us-south"
on_vpc              = false

// Prereqs
worker_node_flavor = "b3c.16x64"

// Entitled Registry parameters:
entitled_registry_key        = "******************"
entitled_registry_user_email = "john.doe@email.com"

// CP4D License Acceptance
accept_cpd_license = true

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

- `enable`: If set to `false` does not install the cloud pak on the given cluster. By default it's enabled
- `on_vpc`: If set to `false`, it will set the install do classic ROKS. By default it's disabled
- `openshift_version`: Openshift version installed in the cluster
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `entitled_registry_user_email`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- `resource_group_name`: Resource group that the cluster is provisioned in
- `accept_cpd_license`: If set to `true`, you accept all cpd license agreements including additional modules installed. By default, it's `false`
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

### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify

To verify installation on the Kubernetes cluster go to the console and go to the `Installed Operators` tab. Click on IBM Cloud Pak for Data and click on `Cloud Pak for Data Service` tab. Finally check the status of the lite-cpdservice.

### Cleanup

Go into the console and delete `cpd_project_name` and `cpd-meta-ops` projects.

Under `kube-system` daemon-sets, remove `norootsquash` and `kernel-optimization`.

Under `openshift-image-registry` routes, remove `image-registry`.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
