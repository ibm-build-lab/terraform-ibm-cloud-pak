# Test CP4S Module

## 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## 2. Test

### Using Terraform client

Follow these instructions to test the Terraform Module manually

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
source          = "./.."
enable          = var.enable

// ROKS cluster parameters:
openshift_version   = var.openshift_version
cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
on_vpc              = var.on_vpc
portworx_is_ready   = var.portworx_is_ready // only need if on_vpc = true

// Prereqs
worker_node_flavor = var.worker_node_flavor

// Entitled Registry parameters:
entitled_registry_key        = var.entitled_registry_key
entitled_registry_user_email = var.entitled_registry_user_email

// CP4D License Acceptance
accept_cpd_license = var.accept_cpd_license

// CP4D Info
cpd_project_name = var.cpd_project_name

// Parameters to install submodules
install_watson_knowledge_catalog = var.install_watson_knowledge_catalog
install_watson_studio            = var.install_watson_studio
install_watson_machine_learning  = var.install_watson_machine_learning
install_watson_open_scale        = var.install_watson_open_scale
install_data_virtualization      = var.install_data_virtualization
install_streams                  = var.install_streams
install_analytics_dashboard      = var.install_analytics_dashboard
install_spark                    = var.install_spark
install_db2_warehouse            = var.install_db2_warehouse
install_db2_data_gate            = var.install_db2_data_gate
install_big_sql                  = var.install_big_sql
install_rstudio                  = var.install_rstudio
install_db2_data_management      = var.install_db2_data_management
```

These parameters are:

- `enable`: If set to `false` does not install the cloud pak on the given cluster. By default it's enabled
- `on_vpc`: If set to `false`, it will set the install do classic ROKS. By default it's disabled
- `openshift_version`: Openshift version installed in the cluster
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `entitled_registry_user_email`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- `accept_cpd_license`: If set to `true`, you accept all cpd license agreements including additional modules installed. By default, it's `false`
- `cpd_project_name` : name of the namespace for the project
- `install_watson_knowledge_catalog`:  Install Watson Knowledge Catalog module. By default it's not installed.
- `install_watson_studio`: Install Watson Studio module. By default it's not installed.
- `install_watson_machine_learning`: Install Watson Machine Learning module. By default it's not installed.
- `install_watson_open_scale`: Install Watson Open Scale module. By default it's not installed. 
- `install_data_virtualization`: Install Data Virtualization module. By default it's not installed.
- `install_streams`: Install Streams module. By default it's not installed.
- `install_analytics_dashboard`: Install Analytics Dashboard module. By default it's not installed.
- `install_spark`: Install Analytics Engine powered by Apache Spark module. By default it's not installed.
- `install_db2_warehouse`: Install DB2 Warehouse module. By default it's not installed.
- `install_db2_data_gate`: Install DB2 Data_Gate module. By default it's not installed.
- `install_big_sql`: Install Big SQL module. By default it's not installed.
- `install_rstudio`: Install RStudio module. By default it's not installed.
- `install_db2_data_management`: Install DB2 Data Management module. By default it's not installed.                                

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

## 3. Verify

To verify installation on the Kubernetes cluster go to the console and go to the `Installed Operators` tab. Click on IBM Cloud Pak for Data and click on `Cloud Pak for Data Service` tab. Finally check the status of the lite-cpdservice.

## 4. Cleanup

Go into the console and delete `cpd_project_name` and `cpd-meta-ops` projects.

Under `kube-system` daemon-sets, remove `norootsquash` and `kernel-optimization`.

Under `openshift-image-registry` routes, remove `image-registry`.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
