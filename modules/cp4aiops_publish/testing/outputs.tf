output "cp4aiops_url" {
  description = "Access your Cloud Pak for AIOPS deployment at this URL."
  value = module.cp4aiops.cp4aiops_endpoint
}

output "cp4aiops_user" {
  description = "Username for your Cloud Pak for AIOPS deployment."
  value = module.cp4aiops.cp4aiops_user
}

output "cp4aiops_password" {
  description = "Password for your Cloud Pak for AIOPS deployment."
  value = module.cp4aiops.cp4aiops_password
}

// Namespace
output "namespace" {
  value = var.namespace
}