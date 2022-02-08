# Example to provision CP4Data Terraform module on AWS

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
customizing these values in the `terraform.tfvars` file:

```hcl
# example url, could be different.
openshift_api             = "https://api.***********.openshiftapps.com:6443/"
openshift_username        = "cluster-admin"
openshift_password        = "**********"
openshift_token           = "<optional>"

# example url, could be different.
login_cmd                 = "oc login https://api.******.openshiftapps.com:6443 --username cluster-admin --password ***********"

installer_workspace       = "/tmp/install"
cpd_external_registry     = "cp.icr.io"
cpd_external_username     = "cp"
cpd_api_key               = "<ENTITLEMENT_KEY>"

storage_option            = "portworx"

## CPD services

cpd_platform              = { "enable" : "yes", "version" : "4.0.1", "channel" : "v2.0" }
watson_knowledge_catalog  = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }
data_virtualization       = { "enable" : "no", "version" : "1.7.1", "channel" : "v1.7" }
analytics_engine          = { "enable" : "no", "version" : "4.0.1", "channel" : "stable-v1" }
watson_studio             = { "enable" : "no", "version" : "4.0.1", "channel" : "v2.0" }
watson_machine_learning   = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.1" }
watson_ai_openscale       = { "enable" : "no", "version" : "4.0.1", "channel" : "v1" }
spss_modeler              = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }
cognos_dashboard_embedded = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }
datastage                 = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }
db2_warehouse             = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }
db2_oltp                  = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }
cognos_analytics          = { "enable" : "no", "version" : "4.0.1", "channel" : "v4.0" }
master_data_management    = { "enable" : "no", "version" : "4.0.1", "channel" : "v1.1" }
decision_optimization     = { "enable" : "no", "version" : "4.0.1", "channel" : "v4.0" }

accept_cpd_license        = "accept"
rosa_cluster              = true

```

These parameters are:

- `openshift_api` : Openshift url
- `openshift_username` : Openshift's username
- `openshift_password` : Openshift's password
- `openshift_token` : For cases where you don't have the password but a token can be generated (e.g SSO is being used) `<optional>`
- `login_cmd` : oc login command to get into an openshift cluster. Usually contains the api url, username, and password.
- `installer_workspace` : Location where files can be downloaded to.
- `cpd_external_registry` : Registry where cpd images can be found
- `cpd_external_username` : Registry user
- `cpd_api_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable.
- `accept_cpd_license` : If set to `accept`, you accept all cpd license agreements including additional modules installed. By default, it's `reject`
- `storage_option` : Sets the type of storage for CPD to use. By default it is `portworx` but it can be `ocs` or `nfs`
- `cpd_platform` : Installs the CPD Dashboard. By default, it's installed.
- `watson_knowledge_catalog` : Install Watson Knowledge Catalog module. By default it's not installed.
- `watson_studio`            : Install Watson Studio module. By default it's not installed.
- `watson_machine_learning`  : Install Watson Machine Learning module. By default it's not installed.
- `watson_ai_openscale`        : Install Watson Open Scale module. By default it's not installed.
- `data_virtualization`      : Install Data Virtualization module. By default it's not installed. 
- `spss_modeler`                  : Install SPSS modeler module. By default it's not installed.
- `cognos_dashboard_embedded`      : Install Cognos Dashboard module. By default it's not installed.
- `analytics_engine`                    : Install Analytics Engine powered by Apache Spark module. By default it's not installed.
- `db2_warehouse`            : Install DB2 Warehouse module. By default it's not installed.
- `db2_oltp`            : Install DB2 OLTP module. By default it's not installed.
- `datastage`                  : Install Datastage module. By default it's not installed.
- `cognos_analytics`                  : Install Cognos Analytics module. By default it's not installed.
- `master_data_management`      : Install Master Data Management module. By default it's not installed.
- `decision_optimization`      : Install Decision Optimization module. By default it's not installed.      
- `rosa_cluster` : Default is `true`, it will use the login_cmd otherwise will build the login command from the api, username, and password.

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

Go into the console and delete `zen`

Under `kube-system` daemon-sets, remove `norootsquash` and `kernel-optimization`.

Under `openshift-image-registry` routes, remove `image-registry`.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
