# Example to provision CP4I Terraform Module

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
setting these values in the `terraform.tfvars` file:

```hcl
cluster_id            = "******************"
on_vpc                = false
region                = "us-south"
resource_group_name   = "Default"
entitled_registry_key = "******************"
entitled_registry_user_email = "john.doe@email.com"
namespace             = "cp4i"
```

These parameters are:

- `cluster_id`: ID of the cluster to install cloud pak on
- `on_vpc`: Set to `true` if the cluster is vpc, `false` if cluster is classic. **NOTE** Portworx must be installed if using a VPC cluster
- `region`: The region that the cluster is provisioned in
- `resource_group_name`: Resource group that the cluster is provisioned in
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `entitled_registry_user_email`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- `namespace`: Name of the namespace cp4i will be installed into


### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify

To verify installation on the Kubernetes cluster, go to the Openshift console and go to the `Installed Operators` tab. Choose your `namespace` and click on `IBM Cloud Pak for Integration Platform Navigator
4.2.0 provided by IBM` and finally click on the `Platform Navigator` tab. Finally check the status of the cp4i-navigator

### Cleanup

Go into the console and delete the platform navigator from the verify section. Delete all installed operators and lastly delete the project.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
