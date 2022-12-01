variable "openshift_api" {
  type    = string
  default = ""
}

variable "openshift_username" {
  type    = string
  default = ""
}

variable "openshift_password" {
  type    = string
  default = ""
}

variable "openshift_token" {
  type        = string
  description = "For cases where you don't have the password but a token can be generated (e.g SSO is being used)"
  default     = ""
}

variable "login_cmd" {
  type = string
}

variable "rosa_cluster" {
  type = bool
}

variable "installer_workspace" {
  type        = string
  description = "Folder find the installation files"
  default     = ""
}

variable "accept_cpd_license" {
  description = "Read and accept license at https://ibm.biz/Bdq6KP, (accept / reject)"
  default     = "reject"
}

variable "cpd_external_registry" {
  description = "URL to external registry for CPD install. Note: CPD images must already exist in the repo"
  default     = "cp.icr.io"
}

variable "cpd_external_username" {
  description = "URL to external username for CPD install. Note: CPD images must already exist in the repo"
  default     = "cp"
}

variable "cpd_api_key" {
  description = "Repository APIKey or Registry password"
}

variable "cpd_namespace" {
  default = "zen"
}

variable "storage_option" {
  type    = string
  default = "portworx"
}

variable "cpd_storageclass" {
  type = map(any)

  default = {
    "portworx" = "portworx-shared-gp3"
    "ocs"      = "ocs-storagecluster-cephfs"
    "nfs"      = "nfs"
  }
}

variable "rwo_cpd_storageclass" {
  type = map(any)

  default = {
    "portworx" = "portworx-metastoredb-sc"
    "ocs"      = "ocs-storagecluster-ceph-rbd"
    "nfs"      = "nfs"
  }
}

###########

variable "cpd_platform" {
  type = map(string)
  default = {
    enable  = "yes"
    version = "4.0.1"
    channel = "v2.0"
  }
}

variable "data_virtualization" {
  type = map(string)
  default = {
    enable  = "no"
    version = "1.7.1"
    channel = "v1.7"
  }
}

variable "analytics_engine" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "stable-v1"
  }
}

variable "watson_knowledge_catalog" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "watson_studio" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v2.0"
  }
}

variable "watson_machine_learning" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.1"
  }
}

variable "watson_ai_openscale" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1"
  }
}

variable "spss_modeler" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "cognos_dashboard_embedded" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "datastage" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "db2_warehouse" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "db2_oltp" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "cognos_analytics" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v4.0"
  }
}

variable "data_management_console" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "master_data_management" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.1"
  }
}

variable "db2_aaservice" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v1.0"
  }
}

variable "decision_optimization" {
  type = map(string)
  default = {
    enable  = "no"
    version = "4.0.1"
    channel = "v4.0"
  }
}

variable "db2u_catalog_source" {
  default = "docker.io/ibmcom/ibm-db2uoperator-catalog:latest"
}