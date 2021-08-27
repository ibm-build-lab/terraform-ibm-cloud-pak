// Use if running on TF version 0.13 or higher
# terraform {
#    required_providers {
#       ibm = {
#          source = "IBM-Cloud/ibm"
#          version = "1.26.2"       
#          }
#     }
# }

terraform {
   required_providers {
      ibm = {
         source = "IBM-Cloud/ibm"
         version = "~>1.12"       
         }
    }
}
