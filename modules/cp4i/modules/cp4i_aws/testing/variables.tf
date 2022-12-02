variable "config_file_path" {
  type        = string
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "storageclass" {
  type        = string
  description = "Name of the chosen storageclass"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

