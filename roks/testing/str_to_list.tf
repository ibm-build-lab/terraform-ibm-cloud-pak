// IBM VPC input parameters and default values : Lists

variable "vpc_zone_names" {
  type    = list(string)
  default = ["us-south-1"]
}
variable "flavors" {
  type    = list(string)
  default = []
}
variable "workers_count" {
  type    = list(number)
  default = [2, 3, 4]
}

// IBM VPC input parameters and default values : Strings

variable "vpc_zone_names_list" {
  type    = string
  default = ""
}
variable "flavors_list" {
  type    = string
  default = "b3c.4x16"
}
variable "workers_count_list" {
  type    = string
  default = "2"
}

// IBM VPC local input parameters and default values : String to Lists

locals {
  vpc_zone_names = length(replace(var.vpc_zone_names_list, " ", "")) > 0 ? split(",", replace(var.vpc_zone_names_list, " ", "")) : var.vpc_zone_names
  flavors        = length(replace(var.flavors_list, " ", "")) > 0 ? split(",", replace(var.flavors_list, " ", "")) : var.flavors
  workers_count  = length(replace(var.workers_count_list, " ", "")) > 0 ? split(",", replace(var.workers_count_list, " ", "")) : var.workers_count
}

// Output Variables : Local Lists Variables

output "vpc_zone_names" {
  value = local.vpc_zone_names
}
output "flavors" {
  value = local.flavors
}
output "workers_count" {
  value = local.workers_count
}
