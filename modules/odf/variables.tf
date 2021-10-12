variable "enable" {
    default     = true
    description = "If set to true installs Portworx on the given cluster"
}
variable "kube_config_path" {
    description = "Path to the k8s config file: ex `~/.kube/config`"
}

variable "cluster_id" {
  description = ""
}

variable "roks_version" {
  description = ""
}
