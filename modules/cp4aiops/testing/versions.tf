terraform {
  required_version = ">= 0.13"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "~> 1.34"
    }
<<<<<<< HEAD
=======
    external = {
      source = "hashicorp/external"
    }
>>>>>>> 7dcb554 (Ran terraform upgrade and fmt)
    null = {
      source = "hashicorp/null"
    }
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 7dcb554 (Ran terraform upgrade and fmt)
