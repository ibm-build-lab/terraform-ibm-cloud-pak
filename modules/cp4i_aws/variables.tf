variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Integration on the given cluster"
}

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "storageclass" {
  default     = "ibmc-file-gold-gid"
  type        = string
  description = "Storage class to use.  If VPC, set to `portworx-rwx-gp3-sc` and make sure Portworx is set up on cluster"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "namespace" {
  default = "cp4i"
  description = "Namespace for Cloud Pak for Integration"
}

locals {
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  entitled_registry_key    = chomp(var.entitled_registry_key)
}
