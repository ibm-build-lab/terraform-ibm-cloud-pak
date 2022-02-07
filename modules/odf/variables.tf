variable "enable" {
    default     = true
    description = "If set to true installs ODF on the given cluster"
}
variable "kube_config_path" {
    description = "Path to the k8s config file: ex `~/.kube/config`"
}

variable "cluster" {
  description = ""
}

variable "roks_version" {
    default = "4.7"
  description = ""
}
