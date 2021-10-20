variable "enable" {
    default     = true
    description = "If set to true installs Portworx on the given cluster"
}

variable "ibmcloud_api_key" {
  description = "Get the ibmcloud api key from https://cloud.ibm.com/iam/apikeys"
}

variable "kube_config_path" {
    description = "Path to the k8s config file: ex `~/.kube/config`"
}

variable "cluster_id" {
    description = "The id of the cluster"
}

variable "region" {
    description = "The region Portworx will be installed in: us-south, us-east, eu-gb, eu-de, jp-tok, au-syd, etc.."
}

variable "resource_group_name" {
    description = "Resource Group in your account. List all available resource groups with: ibmcloud resource groups"
}

variable "roks_version" {
  description = ""
}