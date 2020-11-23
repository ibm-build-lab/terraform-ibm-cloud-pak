# Test ROKS Terraform Module

For a quick test, **[Export the credentials for IBM Cloud Classic or VPC](#1-export-the-credentials-for-ibm-cloud-classic-or-vpc)**, optionally create the file `terraform.tfvars` to **[Define custom tests parameters](#2-define-custom-tests-parameters)**, then use `make` to execute the test on **IBM Cloud Classic**, like so:

```bash
make
make test-kubernetes
make clean
```

Or, to test on **IBM Cloud VPC**, execute:

```bash
make test-vpc
make test-kubernetes
make clean
```

Follow these instructions to execute custom tests to the Terraform module.

## 1. Export the credentials for IBM Cloud Classic or VPC

Execute the following code replacing the values in angular brackets (`< >`) by the respective credentials/keys:

```bash
export IAAS_CLASSIC_USERNAME="< IBM Cloud Username/Email >"
export IAAS_CLASSIC_API_KEY="< IBM Cloud Classic API Key >"
export IC_API_KEY="< IBM Cloud API Key >"
```

Optionally create the file `credentials.sh` with the code above and execute it with `source credentials.sh`. If you choose other filename for the credentials, make sure to include it in the `.gitignore` file or do NOT commit the file to Github.

## 2. Define custom tests parameters

A quick test (executing just `make`) will create a simple cluster on IMB Cloud Classic on the Dallas datacenter. If you'd like to change the region or test environment export the following environment variables:

- `TF_VAR_region` to define the region where to create the cluster, by default is `us-south`. To list all the available regions execute the command `ibmcloud regions`.
- `TF_VAR_datacenter` if you are testing on IBM Cloud Classic, you may define the datacenter where to create the cluster, by default it's Dallas.
- `TF_VAR_cluster_id` the module is to create a cluster, however, if an OpenShift cluster ID is provided in this variable the testing code just verify the `enable` parameter set to `false`. Meaning, the cluster is not created.

The module use the variable `owner` to tag the created resources, using `make` the test set the owner as the Linux or macOS username. If you'd like to use a different username, use the parameter `USER` when execute `make`, like so:

```bash
make USER=tester
```

If you'd like to test with other different parameters, for example, the cluster size, flavor or version, create the file `terraform.tfvars` setting the values for these input variables. Read the file `variables.tf` to know the different parameters you can customize.

By default the test is done on IBM Cloud Classic, to test on VPC use the Make rule `test-vpc` , like this:

```bash
make test-vpc
```

**IMPORTANT**: It's possible you get an error getting the default VLAN numbers on IBM Cloud Classic, this is caused by the permissions on the account. If this happens, you need to pass the values of the private and public VLAN numbers as an input. To obtain the VLAN numbers execute the following command, where `DATACENTER` is the value of the datacenter parameter:

```bash
❯ ibmcloud ks vlan ls --zone $DATACENTER
OK
ID        Name   Number   Type      Router         Supports Virtual Workers
2979232          2146     private   bcr01a.dal10   true
2979230          2341     public    fcr01a.dal10   true
```

If you have multiple VLAN numbers, get those without name. Identify the private and public by the **Type** column and provide just the numbers in the **ID** column. Like so in the `terraform.tfvars` file:

```yaml
private_vlan_number = "2979232"
public_vlan_number  = "2979230"
```

If there isn't any VLAN number in that datacenter, do not provide any as input variable, they will be created by the module.

## 3. Test

Having the credentials set and the `terraform.tfvars` file with custom parameters, the simplest way to run the test is to execute `make` to test on IBM Cloud Classic, or `make test-vpc` to test on IBM Cloud VPC.

The other manual way to run the test, is to execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## 4. Test the Kubernetes cluster

To test the Kubernetes cluster you need `kubectl`, then execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info
kubectl get namespace terraform-module-is-working
```

Or any other `kubectl` or `oc` command.

## 5. Destroy

When tests is successfully complete, execute: `terraform destroy` and delete all the created files. Or, just execute `make clean`
