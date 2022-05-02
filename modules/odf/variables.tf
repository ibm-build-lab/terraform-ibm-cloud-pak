variable "is_enable" {
    default     = true
}

variable "cluster" {
  type = string
  description = "Cluster name on which ODF is to be enabled"
}

variable "ibmcloud_api_key" {
  type = string
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "roks_version" {
  type = string
  description = "ROKS Cluster version (4.7 or higher)"
}

variable "osdStorageClassName" {
  description = "Storage class that you want to use for your OSD devices"
  type = string
  default = "ibmc-vpc-block-10iops-tier"
}

variable "osdSize" {
  description = "Size of your storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd."
  type = string
  default = "100Gi"
}

variable "numOfOsd" {
  description = "Number object storage daemons (OSDs) that you want to create. ODF creates three times the numOfOsd value."
  default = 1
}

variable "billingType" {
  description = "Billing Type for your ODF deployment (`essentials` or `advanced`)."
  type = string
  default = "advanced"
}

variable "ocsUpgrade" {
  description = "Whether to upgrade the major version of your ODF deployment."
  type = bool
  default = false
}

variable "clusterEncryption" {
  description = "Enable encryption of storage cluster"
  type = bool
  default = false
}

# Options required for Openshift 4.7 only
variable "monSize" {
  description = "Size of the storage devices that you want to provision for the monitor pods. The devices must be at least 20Gi each"
  type = string
  default = "20Gi"
}

variable "monStorageClassName" {
  description = "Storage class to use for your Monitor pods. For VPC clusters you must specify a block storage class"
  type = string
  default = "ibmc-vpc-block-10iops-tier"
}