# Example using the Terraform Module to install an Openshift (ROKS) cluster on IBM Cloud.

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../../../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud. Go [here](../../../CREDENTIALS.md) for details.

For instructions to run using the local Terraform Client on your local machine go [here](../../../Using_Terraform.md). 

Set values for required input variables in the file `terraform.tfvars`. Pay attention to the sections required for **Classic** vs **VPC**.
 
Examples have been provided as `terraform.tfvars.classic` and `terraform.tfvars.vpc`.

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


## Verify the Kubernetes cluster

To test the cluster using `kubectl`, execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info
kubectl get namespace terraform-module-is-working
```

Or any other `kubectl` or `oc` command.

## Destroy

To delete the cluster, execute: `terraform destroy` and delete all the created files.
