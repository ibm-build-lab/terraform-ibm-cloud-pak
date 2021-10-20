output "CLASSIC_ID" {

  value = var.enable && length(ibm_compute_vm_instance.ldap) > 0 ? ibm_compute_vm_instance.ldap.0.id : ""

}

output "CLASSIC_IP_ADDRESS" {

  value = var.enable && length(ibm_compute_vm_instance.ldap) > 0 ? ibm_compute_vm_instance.ldap.0.ipv4_address : ""

}

output "ldapBindDN" {

  value = var.ldapBindDN

}

output "ldapBindDNPassword" {

  value = var.ldapBindDNPassword

}