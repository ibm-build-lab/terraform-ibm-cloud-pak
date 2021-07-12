# Test CP4AIOPS Module

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
  source    = "../../modules/cp4aiops"
  enable    = var.enable

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = var.portworx_is_ready // set to 1 if portworx is installed or classic

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  namespace = var.namespace
```

These parameters are:

- `enable`: If set to `false` does not install the cloud pak on the given cluster. By default it's enabled
- `cluster_config_path`: Kube config directory path
- `on_vpc`: Set to true if the cluster is vpc
- `portworx_is_ready`: Set to `1` if portworx is installed or if it's  a classic cluster
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `entitled_registry_user_email`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- `namespace`: Name of the namespace cp4aiops will be installed into
                            

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

## 3. Verify

To verify installation on the Kubernetes cluster, take the output URL, username and password and log into the CP4AIOps console.

## 4. Cleanup

Go into the console and delete the installation `ibm-cp-watson-aiops` from the installations tab located within the IBM Cloud Pak for Watson AIOps operaator. Next, delete all installed operators and lastly delete the project.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
