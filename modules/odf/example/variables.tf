variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
}

variable "cluster" {
    description = "The id of the cluster"
    type = string
}

variable "roks_version" {
  type = string
  description = "ROKS Cluster version (4.7 or higher)"
}

variable "osdStorageClassName" {
  description = "Storage class that you want to use for your OSD devices"
  type = string
  default = "ibmc-vpc-block-metro-10iops-tier"
}

variable "osdDevicePaths" {
  description = "Please provide IDs of the disks to be used for OSD pods if using local disks or standard classic cluster"
  type = string
  default = ""
}

variable "osdSize" {
  description = "Size of your storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd."
  type = string
  default = "250Gi"
}

variable "numOfOsd" {
  description = "Number object storage daemons (OSDs) that you want to create. ODF creates three times the numOfOsd value."
  default = "1"
}

variable "billingType" {
  description = "Billing Type for your ODF deployment (`essentials` or `advanced`)."
  type = string
  default = "advanced"
}

variable "ocsUpgrade" {
  description = "Whether to upgrade the major version of your ODF deployment."
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
  description = "Size of the storage devices that you want to provision for the monitor pods. The devices must be at least 20Gi each"
  type = string
  default = "20Gi"
}

variable "monStorageClassName" {
  description = "Storage class to use for your Monitor pods. For VPC clusters you must specify a block storage class"
  type = string
  default = "ibmc-vpc-block-metro-10iops-tier"
}

variable "monDevicePaths" {
  description = "Please provide IDs of the disks to be used for mon pods if using local disks or standard classic cluster"
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
  description = "Enter your Hyper Protect Crypto Services instance ID. For example: d11a1a43-aa0a-40a3-aaa9-5aaa63147aaa"
  type = string
  default = ""
}

variable "hpcsSecretName" {
  description = "Enter the name of the secret that you created by using your Hyper Protect Crypto Services credentials. For example: ibm-hpcs-secret"
  type = string
  default = ""
}

variable "hpcsBaseUrl" {
  description = "Enter the public endpoint of your Hyper Protect Crypto Services instance. For example: https://api.eu-gb.hs-crypto.cloud.ibm.com:8389"
  type = string
  default = ""
}

variable "hpcsTokenUrl" {
  description = "Enter https://iam.cloud.ibm.com/oidc/token"
  type = string
  default = ""
}