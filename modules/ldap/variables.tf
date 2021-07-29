variable "ibmcloud_api_key" {
    default = null
    description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
    default = null
    description = "Region code (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)"
}

variable "iaas_classic_api_key" {
    default = null
    description = "IBM Classic Infrastucture API Key (https://cloud.ibm.com/docs/account?topic=account-classic_keys)"

}

variable "iaas_classic_username" {
    default = null
    description = "IBM Classic Infrastucture API Key (see https://cloud.ibm.com/docs/account?topic=account-classic_keys)"

}

variable "ibmcloud_domain" {
    default = null
    description = "IBM Cloud account Domain, example <My Company>.cloud"

}

variable "os_reference_code" {
    default = null
    description = "The Operating System Reference Code, for example CentOS_8_64 (see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)"

}

variable "cores" {
    default = null
    description = "Virtual Server CPU Cores"

}

variable "memory" {
    default = 4096
    description = "Virtual Server Memory"
}

variable "disks" {
    default     =   [25]
    description = "Boot disk size"
}

variable "hostname" {
    default     = "ldapvm"
    description = "Hostname of the virtual Server"
}

variable "datacenter" {
    default = null
    description = "IBM Cloud Datacenter"
}
