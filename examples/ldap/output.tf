output "ldap_id" {
  description = "LDAP server id"
  value = module.ldap.CLASSIC_ID
}

output "ldap_ip_address" {
  description = "IP address for LDAP server"
  value = module.ldap.CLASSIC_IP_ADDRESS
}

