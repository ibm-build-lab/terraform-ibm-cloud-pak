variable "openshift_version" {
  default     = "4.6_openshift"
  description = "Openshift version installed in the cluster"
}

locals {
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}

output "openshift_version" {
  value = local.openshift_version_number
}
