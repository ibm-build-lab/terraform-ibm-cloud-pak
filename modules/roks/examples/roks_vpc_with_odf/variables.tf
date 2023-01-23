
variable "ibmcloud_api_key" {
  default = ""
  description = "IBMCloud API Key for the account the resources will be provisioned on. Go here to create an ibmcloud_api_key: https://cloud.ibm.com/iam/apikeys"
}

variable "entitlement" {
  default     = "cloud_pak"
  description = "Ignored if `cluster_id` is specified. Enter 'cloud_pak' if using a Cloud Pak entitlement.  Leave blank if OCP entitlement"
}

variable "region" {
  default     =  "ca-tor" //"us-south"
  description = "Region that the cluster is/will be located. List all available regions with: `ibmcloud regions`"
}

variable "resource_group" {
  default     = "Default"
  description = "Resource group that the cluster is/will be located. List all available resource groups with: `ibmcloud resource groups`"
}

variable "roks_version" {
  default     = "4.10"
  type = string
  description = "Ignored if `cluster_id` is specified. List available versions: `ibmcloud ks versions`"
}

variable "project_name" {
  default     = "roks"
  description = "Ignored if `cluster_id` is specified. The project name is used to name the cluster with the environment name"
}

variable "owner" {
  default     = "anonymous"
  description = "Optional. User name or team name. The owner is used to label the cluster and other resources"
}

variable "environment" {
  default     = "test"
  description = "The environment name is used to name the cluster with the project name"
}

variable "force_delete_storage" {
  type        = bool
  default     = true
  description = "If set to true, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is false"
}

// OpenShift cluster specific input parameters and default values:
variable "flavors" {
  type    = list(string)
  default = ["bx2.16x64"]
  description = "Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. On VPC can list multiple flavors `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"bx2.16x64\"]`"
}

variable "workers_count" {
  type    = list(number)
  default = [5]
  description = "Array with the amount of workers on each workers group. Classic set up only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

variable "vpc_zone_names" {
  type    = list(string)
  default = ["ca-tor-1"]  //["us-south-1"]
  description = "**VPC only**. Array with the subzones in the region to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example [\"us-south-1\", \"us-south-2\", \"us-south-3\"]"
}

// ODF Variables
variable "osdStorageClassName" {
  description = "Storage class that you want to use for your OSD devices"
  type = string
  default = "ibmc-vpc-block-metro-10iops-tier"
}

variable "osdDevicePaths" {
  description = "IDs of the disks to be used for OSD pods if using local disks or standard classic cluster"
  type = string
  default = ""
}

variable "osdSize" {
  description = "Size of storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd."
  type = string
  default = "250Gi"
}

variable "numOfOsd" {
  description = "Number object storage daemons (OSDs) that to create. ODF creates three times the numOfOsd value."
  default = "1"
}

variable "billingType" {
  description = "Billing Type for ODF deployment (`essentials` or `advanced`)."
  type = string
  default = "advanced"
}

variable "ocsUpgrade" {
  description = "Whether to upgrade the major version of ODF deployment."
  # type = bool
  default = "false"
}

variable "clusterEncryption" {
  description = "Enable encryption of storage cluster"
  # type = bool
  default = "false"
}

# variable "workerNodes" {
#   description = "Optional: Enter the node names for the worker nodes that you want to use for your ODF deployment. Don't specify this parameter if you want to use all the worker nodes in your cluster."
# }

# Options available for Openshift 4.7 only. Run command `ibmcloud oc cluster addon options --addon openshift-data-foundation --version 4.7.`
variable "monSize" {
  description = "Size of the storage devices to provision for the monitor pods. The devices must be at least 20Gi each"
  type = string
  default = "20Gi"
}

variable "monStorageClassName" {
  description = "Storage class to use for Monitor pods. For VPC clusters must specify a block storage class"
  type = string
  default = "ibmc-vpc-block-metro-10iops-tier"
}

variable "monDevicePaths" {
  description = "IDs of the disks to be used for mon pods if using local disks or standard classic cluster"
  type = string
  default = ""
}

# Options available for Openshift 4.8, 4.9, 4.10 only.  Run command `ibmcloud oc cluster addon options --addon openshift-data-foundation --version <version>.`
variable "autoDiscoverDevices" {
  description = "Auto Discover Devices"
  type = string
  default = "false"
}

# Options available for Openshift 4.10 only.  Run command `ibmcloud oc cluster addon options --addon openshift-data-foundation --version <version>.`
variable "hpcsEncryption" {
  description = "Use Hyper Protect Crypto Services"
  # type = bool
  default = "false"
}

variable "hpcsServiceName" {
  description = "Enter the name of your Hyper Protect Crypto Services instance. For example: Hyper-Protect-Crypto-Services-eugb"
  type = string
  default = ""
}

variable "hpcsInstanceId" {
  description = "Hyper Protect Crypto Services instance ID. For example: d11a1a43-aa0a-40a3-aaa9-5aaa63147aaa"
  type = string
  default = ""
}

variable "hpcsSecretName" {
  description = "Name of the secret that you created by using your Hyper Protect Crypto Services credentials. For example: ibm-hpcs-secret"
  type = string
  default = ""
}

variable "hpcsBaseUrl" {
  description = "Public endpoint of your Hyper Protect Crypto Services instance. For example: https://api.eu-gb.hs-crypto.cloud.ibm.com:8389"
  type = string
  default = ""
}

variable "hpcsTokenUrl" {
  description = "Enter the result of https://iam.cloud.ibm.com/oidc/token"
  type = string
  default = ""
}