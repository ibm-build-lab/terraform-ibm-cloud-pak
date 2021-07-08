# Running examples using local Terraform client

## Requirements

To run locally, these examples have the following dependencies:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-terraform) **version 0.12**
- [Install IBM Cloud Terraform Provider](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#configure-access-to-ibm-cloud)
- [Configure Access to IBM Cloud](./CREDENTIALS.md)
- Utility tools such as:
  - [jq](https://stedolan.github.io/jq/download/)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  - [oc](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html)

Execute these commands to validate some of these requirements:

```bash
ibmcloud --version
ibmcloud plugin show schematics | head -3
ibmcloud plugin show kubernetes-service | head -3
ibmcloud target
terraform version
ls ~/.terraform.d/plugins/terraform-provider-ibm_*
```

## Executing the examples
1. Move into the directory of the desired Cloud Pak to install, for example:

   ```bash
   cd iaf
   ```

2. Create the file `terraform.tfvars` with the following Terraform input variables using your own specific values.  Refer to each example README for the specific variables to override:

   ```hcl
   owner                        = "bob"
   project_name                 = "cloud-pak-app"
   entitled_registry_user_email = "bob@email.com"
   cluster_id                   = "xxxxxxxxxxxxxxxxxxxxx"
   ibmcloud_api_key             = "xxxxxxxxxxxxxxxxxxxxx"
   ...
   ```

3. Issue the following commands to prime the Terraform code:

   ```bash
   terraform init
   ```

   If you modified the code, execute the following commands to validate and format the code:

   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan
   ```

4. Issue the following command to execute the Terraform code:

   ```bash
   terraform apply -auto-approve
   ```

   At the end of the execution you'll see the output parameters.

   If something fails, it should be safe to execute the `terraform apply` command again.

5. To get the output parameters again or validate them, execute:

   ```bash
   terraform output
   ```

6. Finally, when you finish using the infrastructure, cleanup everything you created with the execution of:

   ```bash
   terraform destroy
   ```
