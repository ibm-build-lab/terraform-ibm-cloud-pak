# Example to provision CP4BA Terraform Module

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md). 

Set the desired values in the `terraform.tfvars` file. These are examples:

```hcl
cluster_name_or_id = "********************"
resource_group = "cloud-pak-sandbox-ibm"
entitlement_key = "*********************"
entitled_registry_user = "john.doe@ibm.com"
ldap_admin = "cn=root"
ldap_password = "Passw0rd"
ldap_host_ip = "xx.xx.xxx.xxx"
db2_admin = "cpadmin"
db2_user = "db2inst1"
db2_password = "Passw0rd"
db2_host_name = "db2testhost.us-south.containers.appdomain.cloud"
db2_host_port = "30788"
```

These parameters are:

- `cluster_name_or_id`: Name or ID of the cluster to install cloud pak on
- `resource_group_name`: Resource group that the cluster is provisioned in
- `entitlement_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable
- `entitled_registry_user`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- ldap_admin: LDAP root user name
- ldap_password: LDAP password
- ldap_host_ip: "xx.xx.xxx.xxx"
- db2_admin: DB2 admin user name as set up in LDAP
- db2_user: DB2 user name as set up in LDAP
- db2_password: DB2 user password as set up in LDAP
- db2_host_name: DB2 Host name
- db2_host_port: DB2 Host Port

### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify

To verify installation on the Kubernetes cluster, go to the Openshift console and go to the `Installed Operators` tab. Choose your `namespace` and click on `IBM Cloud Pak for Business Automation

## Accessing the Cloud Pak Console

Check to make sure that the icp4ba cartridge in the IBM Automation Foundation Core is ready. For more information about IBM Automation Foundation, see [What is IBM Automation foundation](https://www.ibm.com/support/knowledgecenter/en/cloudpaks_start/cloud-paks/about/overview-cp.html)?

To view the status of the `icp4ba` cartridge in the OCP Admin console, click **Operators > Installed Operators > IBM Automation Foundation Core**. Click the Cartridge tab, click `icp4ba`, and then scroll to the Conditions section.

When the deployment is successful, a ConfigMap is created in the CP4BA namespace (project) to provide the cluster-specific details to access the services and applications. The ConfigMap name is prefixed with the deployment name (default is icp4adeploy). You can search for the routes with a filter on `cp4ba-access-info`.

The contents of the ConfigMap depends on the components that are included. Each component has one or more URLs, and if needed a username and password. Each component has one or more URLs.

```
<component1> URL: <RouteUrlToAccessComponent1>  
<component2> URL: <RouteUrlToAccessComponent2> 
```

You can find the URL for the Zen UI by clicking **Network > Routes** and looking for the name cpd, or by running the following command.

```console
oc get route |grep "^cpd"
  ```
  
You can get the default username by running the following command:

```console
oc -n ibm-common-services get secret platform-auth-idp-credentials \
   -o jsonpath='{.data.admin_username}' | base64 -d && echo
```
You get the password by running the following command:
```console

oc -n ibm-common-services get secret platform-auth-idp-credentials \
   -o jsonpath='{.data.admin_password}' | base64 -d
```
## Cleanup

Go into the console and delete the platform navigator from the verify section. Delete all installed operators and lastly delete the project.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
