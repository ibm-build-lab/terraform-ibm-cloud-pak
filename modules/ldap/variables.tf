variable "enable" {
  default     = true
  description = "Flag to enable or disable the module to create the LDAP server"
}

variable "ibmcloud_api_key" {
  default     = null
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  default     = null
  description = "Region code (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)"
}

variable "iaas_classic_api_key" {
  default     = null
  description = "IBM Classic Infrastucture API Key (https://cloud.ibm.com/docs/account?topic=account-classic_keys)"

}

variable "iaas_classic_username" {
  default     = null
  description = "IBM Classic Infrastucture API Key (see https://cloud.ibm.com/docs/account?topic=account-classic_keys)"

}

variable "ibmcloud_domain" {
  default     = null
  description = "IBM Cloud account Domain, example <My Company>.cloud"

}

variable "os_reference_code" {
  default     = null
  description = "The Operating System Reference Code, for example CentOS_8_64 (see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)"

}

variable "cores" {
  default     = null
  description = "Virtual Server CPU Cores"

}

variable "memory" {
  default     = null
  description = "Virtual Server Memory"
}

variable "disks" {
  default     = null
  description = "The numeric disk sizes in GBs for the instance's block device and disk image settings."
}

variable "hostname" {
  default     = "ldapvm"
  description = "Hostname of the virtual Server"
}

variable "datacenter" {
  default     = ""
  description = "IBM Cloud data center in which you want to provision the instance."
}

variable "network_speed" {
  default     = 100
  description = "The connection speed (in Mbps) for the instance's network components. The default value is 100"
}

variable "hourly_billing" {
  default     = true
  description = "The billing type for the instance. When set to true, the computing instance is billed on hourly usage. Otherwise, the instance is billed monthly. The default value is true."
}

variable "private_network_only" {
  default     = false
  description = "When set to true, a compute instance has only access to the private network. The default value is false."
}

variable "local_disk" {
  default     = true
  description = "The disk type for the instance. When set to true, the disks for the computing instance are provisioned on the host that the instance runs. Otherwise, SAN disks are provisioned. The default value is true."
}
variable "ldapBindDN" {
  default     = "cn=root"
  description = "Bind DN (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d)"
}
variable "ldapBindDNPassword" {
  default     = null
  description = "Bind DN Password (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d)"
}
