# Licensed Source of IBM Copyright IBM Corp. 2020, 2021
variable "enable" {
    default     = true
    description = "If set to true installs Portworx on the given cluster"
}

variable "ibmcloud_api_key" {
    description = "Get the api key from https://cloud.ibm.com/iam/apikeys"
}

variable "base_name" {
    description = "The name of the portworx service"
}

variable "dc_region" {
    description = "The region Portworx will be installed in: us-south, us-east, eu-gb, eu-de, jp-tok, au-syd, etc.."
}

variable "cluster_name" {
    description = "The name of the cluster"
}

# storage option
variable "storage_capacity"{
    type = number
    default = 200
    description = "Storage capacity in GBs"
}

variable "storage_region"{
    type = string
    description = "This is the region where the storage will be created. Example us-south-1, us-east-1, etc."
}

# options: "px-dr-enterprise", "px-enterprise"
variable "plan" {
    default = "px-enterprise" # Note that the account will be charged with portworx license fee
    description = "Available options are px-dr-enterprise or px-enterprise"
}


variable "resource_group_name" {
    description = "Resource Group in your account. List all available resource groups with: ibmcloud resource groups"
}


variable "px_tags" {
    type        = list(string)
    description = "Provide the cluster name. Do not provide any other tags. Example [\"cluster-name\"]"
}

# options - "external", "internal"
variable "kvdb" {
    default = "internal"
    description = "Available options are external or interanal"
}

### value should be consistance with  set value in portworx-secret implementation
variable "etcd_secret"{
    default = "px-etcd-certs"
    description = "Value should be consistance with  set value in portworx-secret implementation"
}

# options - "ibm-kp", "k8s"
variable "secret_type"{
    default = "k8s"
    description = "Available options are ibm-kp or k8s"
}
