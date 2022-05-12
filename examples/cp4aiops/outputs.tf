output "cp4aiops_aiman_url" {
  description = "Access your Cloud Pak for AIOPS AIManager deployment at this URL."
  value = module.cp4aiops.ai_manager_endpoint
}

output "cp4aiops_aiman_user" {
  description = "Username for your Cloud Pak for AIOPS AIManager deployment."
  value = module.cp4aiops.ai_manager_user
}

output "cp4aiops_aiman_password" {
  description = "Password for your Cloud Pak for AIOPSAIManager  deployment."
  value = module.cp4aiops.ai_manager_password
}

output "cp4aiops_evtman_url" {
  description = "Access your Cloud Pak for AIOP EventManager deployment at this URL."
  value = module.cp4aiops.event_manager_endpoint
}

output "cp4aiops_evtman_user" {
  description = "Username for your Cloud Pak for AIOPS EventManager deployment."
  value = module.cp4aiops.event_manager_user
}

output "cp4aiops_evtman_password" {
  description = "Password for your Cloud Pak for AIOPS EventManager deployment."
  value = module.cp4aiops.event_manager_password
}