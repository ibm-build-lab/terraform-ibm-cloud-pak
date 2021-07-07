# Provisioning a Cloud Pak Sandbox using a Private Catalog

To release a new version of the Private Catalog execute the `make` command which will create the file `product/CPS-MCM-1.x.y.tgz` file with all the code required for the Catalog Product.

```bash
make build
```

Create a [release](https://github.com/ibm-hcbt/cloud-pak-sandboxes/releases) in GitHub, assign a version and upload the created `.tgz` to the attached binaries.

Copy the URL to this file.

Then, follow these instructions on the IBM Cloud Web Console:

1. Go to **IBM Cloud Console** > **Manage** > **Catalogs** > **Private catalogs**, create or select the catalog "_Cloud Pak Cluster Sandbox_", then go to **Private products**
2. Add a product, select **Private repository**, and paste the release binary URL previously copied
3. Add **ALL** the Deployment values
4. **Edit** the parameters for the following Deployment values:
   1. **owner**: Required
   2. **project_name**: Required
5. Click on **Update** and go to **Validate product**, enter the values for the parameters:
   1. **resource group** (at the header and in section **Parameters with default values**): example: `cloud-pak-sandbox`
   2. **owner**, **project_name**: example: `johandry` and `cp-sandbox`
6. Double check the other deployment values, use the `ibmcloud` commands in the description if required.
7. Click on **Validate** and wait. It's recommended to check the logs (click on **View logs** link) in the created Schematics workspace
8. Once validated, you can **Publish to account** the Catalog, then to staging and production. (so far just to account until it's validated by the team and ready to be released)

## Use the Private Catalog

This Private Catalog creates an Openshift (ROKS) cluster on IBM Cloud Classic with a Cloud Pak.

Follow these instruction to open the Private Catalog:

1. Open the IBM Cloud Console, go to **Catalog** and select **Cloud-Pak Cluster Sandbox**
2. Select the tile **ROKS**
3. Select the **Resource Group** to create the cluster, for example: `cloud-pak-sandbox`. Assign the same value to **resource_group** in the section **Parameters with default values**
4. In the section **Parameters without default values**, assign values to: **owner**, **project_name**. These parameters are used to identify your cluster. Use your name or team name and what project that will be using this cluster.
5. In the section **Parameters with default values**, validate the value of the OpenShift version to install. Execute in a terminal `ibmcloud ks versions` to list all the available versions.
6. In the same section, assign or verify the value of the parameter **region**. In a terminal, execute `ibmcloud is regions` to select a valid region.
7. In the same section, select a value for the parameter **infra**. select either `classic` or `vpc`, depending of where you would like the cluster.
8. If the cluster will be created on **IBM Cloud Classic** (`infra` = `classic`), assign or verify the following parameters in the section **Parameters without default values**:
   - **datacenter**. In a terminal, execute: `ibmcloud ks zone ls --provider classic` to list all the available options.
   - **size** with the number of workers in the cluster. Also, verify or change the parameter
   - **flavor** with the machine type of the workers. Execute in a terminal `ibmcloud ks flavors --zone <ZONE>` to know the available machine type in the selected zone (replace `<ZONE>` with the selected zone). For example, in the zone `dal10`, one of the available flavors is `b3c.4x16`.
   - The values of the parameters listed in the following step (#9) are ignored, you can have any value there.
9. If the cluster is to be created on **IBM Cloud VPC** (`infra` = `vpc`), assign or verify the following parameters in the section **Parameters without default values**:
   - **vpc_zone_names_list**. In a terminal, execute: `ibmcloud ks zone ls --provider vpc-gen2` to list all the available sub-zones in the selected region on step #6, for example: `us-south-1`. On IBM Cloud VPC can be created multiple worker pools on different sub-zones, separate the multiple sub-zones with a coma, like so: `us-south-1, us-south-2, us-south-3`
   - **flavors_list**. In the terminal, execute `ibmcloud ks flavors --zone <ZONE> --provider vpc-gen2` for each selected zones in the step 9.1, for example: `mx2.4x32` if the zone is `us-south-1`. If you choose multiple zones make sure the amount of flavors is the same, for example if 3 zones where selected the flavors could be: `mx2.4x32, mx2.8x64, cx2.4x8`.
   - **workers_count_list** with the number of workers per sub-zone, they cannot be less than 2 per zone. For example, if you choose one zone the value can be: `2`, if the amount of zones is 3 the value can be: `2,3,2`.
   - The values of the parameters listed in the previous step (#8) are ignored, you can have any value there.
10. Click on the **Install** button, in a few seconds you'll see the logs from the Schematics workspace with the creation of the cluster.
