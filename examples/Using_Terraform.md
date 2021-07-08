# Running examples using Terraform

1. Make sure you have all the [requirements](./README.md#requirements) set. (Terraform, IBM Cloud CLI, IBM Cloud credentials, etc...)

2. Move into the directory of the desired Cloud Pak to install, for example, if you'd like to install CP4MCM:

   ```bash
   cd iaf
   ```

3. Create the file `terraform.tfvars` with the following Terraform input variables using your own specific values.  Refer to each example README for the specific variables to override:

   ```hcl
   owner                        = "bob"
   project_name                 = "cloud-pak-app"
   entitled_registry_user_email = "bob@email.com"
   cluster_id                   = "xxxxxxxxxxxxxxxxxxxxx"
   ibmcloud_api_key             = "xxxxxxxxxxxxxxxxxxxxx"
   ...
   ```

4. Issue the following commands to prime the Terraform code:

   ```bash
   terraform init
   ```

   If you modified the code, execute the following commands to validate and format the code:

   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan
   ```

5. Issue the following command to execute the Terraform code:

   ```bash
   terraform apply -auto-approve
   ```

   At the end of the execution you'll see the output parameters.

   If something fails, it should be safe to execute the `terraform apply` command again.

6. To get the output parameters again or validate them, execute:

   ```bash
   terraform output
   ```

7. Finally, when you finish using the infrastructure, cleanup everything you created with the execution of:

   ```bash
   terraform destroy
   ```
