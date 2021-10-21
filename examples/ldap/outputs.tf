output "ldap_id" {
  value = module.ldap.CLASSIC_ID
}

output "ldap_ip_address" {
  value = module.ldap.CLASSIC_IP_ADDRESS
}

output "ldapBindDN" {
  value = module.ldap.ldapBindDN
}

output "ldapBindDNPassword" {
  value = module.ldap.ldapBindDNPassword
}
