variable "region" {
  type        = string
  description = "AWS Region the cluster is deployed in"
}


variable "portworx_enterprise" {
  type        = map(string)
  description = "See PORTWORX-ENTERPRISE.md on how to get the Cluster ID."
  default = {
    enable            = false
    cluster_id        = ""
    enable_encryption = true
  }
}

variable "portworx_essentials" {
  type        = map(string)
  description = "See PORTWORX-ESSENTIALS.md on how to get the Cluster ID, User ID and OSB Endpoint"
  default = {
    enable       = false
    cluster_id   = ""
    user_id      = ""
    osb_endpoint = ""
  }
}

variable "disk_size" {
  description = "Disk size for each Portworx volume"
  default     = 200
}

variable "kvdb_disk_size" {
  default = 200
}

variable "px_enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable monitoring on PX"
}

variable "px_enable_csi" {
  type        = bool
  default     = true
  description = "Enable CSI on PX"
}

variable "access_key_id" {
  type = string
}

variable "secret_access_key" {
  type = string
}