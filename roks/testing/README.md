# Test ROKS Terraform Module

Follow these instructions to execute custom tests to the Terraform module.

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## 2. Define custom test parameters

Set values for required input variables in the file `terraform.tfvars`. Pay attention to the sections required for **Classic** vs **VPC**.

**IMPORTANT**: for **classic** you need to pass the values of the private and public VLAN numbers as an input if they exist. To obtain the VLAN numbers execute the following command:

```bash
❯ ibmcloud ks vlan ls --zone <data_center>
OK
ID        Name   Number   Type      Router         Supports Virtual Workers
2979232          2146     private   bcr01a.dal10   true
2979230          2341     public    fcr01a.dal10   true
```

If you have multiple VLAN numbers, choose one. Identify the private and public by the **Type** column and provide just the numbers in the **ID** column:

```yaml
private_vlan_number = "2979232"
public_vlan_number  = "2979230"
```

If there aren't any VLANs in that datacenter, leave as empty strings and they will be created by the module.

## 3. Test

Using your local Terraform client, run the test by executing execute the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## 4. Test the Kubernetes cluster

To test the cluster using `kubectl`, execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info
kubectl get namespace terraform-module-is-working
```

Or any other `kubectl` or `oc` command.

## 5. Destroy

When tests is successfully complete, execute: `terraform destroy` and delete all the created files.
