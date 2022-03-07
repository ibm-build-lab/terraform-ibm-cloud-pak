variable "is_enable" {
  default     = true
  description = "If set to true installs ODF on the given cluster"
}

variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
}

variable "cluster" {
    description = "The id of the cluster"
}
