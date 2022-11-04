/**************************************************************************************************************
To Write a test file, use following link as a reference

https://github.com/terraform-ibm-modules/terraform-ibm-function/blob/main/test/cloud_function_test.go

***************************************************************************************************************/

/**************************************************************************************************************
To Write a test file, use following link as a reference

https://github.com/terraform-ibm-modules/terraform-ibm-function/blob/main/test/cloud_function_test.go

***************************************************************************************************************/
package test

import (
 	"testing"
    	"os"
	/*"fmt"*/
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// An example of how to test the Terraform module to create cos instance in examples/instance using Terratest.
func TestAccIBMCP4AIOPS(t *testing.T) {
	t.Parallel()

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/cp4aiops_on_roks_classic",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":     		            "ca-tor",
			"worker_zone":		            "tor01",
			"resource_group":	            os.Getenv("RESOURCE_GROUP"),
			"workers_count":	            5,
			"worker_pool_flavor":	        "b3c.16x64",
			"public_vlan":		            os.Getenv("PUBLIC_VLAN"),
			"private_vlan":		            os.Getenv("PRIVATE_VLAN"),
			"force_delete_storage":	        true,
			"project_name":		            "cp4aiops",
			"environment":		            "test",
			"owner":		                "terratest",
			"roks_version":		            os.Getenv("ROKS_VERSION"),
			"entitled_registry_key":	    os.Getenv("CP_ENTITLEMENT"), //pragma: allowlist secret
			"entitled_registry_user_email":	os.Getenv("CP_ENTITLEMENT_EMAIL"),
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
