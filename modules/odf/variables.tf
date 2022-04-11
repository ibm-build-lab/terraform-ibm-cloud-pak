variable "is_enable" {
    default     = true
}

variable "cluster" {
  description = "Provide cluster id"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "osdStorageClassName" {
  default = "ibmc-vpc-block-metro-10iops-tier"
}

variable "osdSize" {
  default = "800Gi"
}

variable "numOfOsd" {
  default = 3
}

variable "billingType" {
  default = "essentials"
}

variable "ocsUpgrade" {
  default = false
}

variable "monSize" {
  default = "20Gi"
}

variable "monStorageClassName" {
  default = "localfile"
}