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
func TestAccIBMCP4I(t *testing.T) {
	t.Parallel()

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/roks_classic_with_cp4i",

		// Variables to pass to our Terraform code using -var options
		// Settings are for cloud account Humio 2129514
		Vars: map[string]interface{}{
			"region":     		"ca-tor",
			"worker_zone":		"tor01",
			"resource_group":	"cloud-pak-sandbox-ibm",
			"workers_count":	4,
			"worker_pool_flavor":	"b3c.16x64",
			"public_vlan":		"3225444",
			"private_vlan":		"3225446",
			"force_delete_storage":	true,
			"project_name":		"ann-cp4i",
			"environment":		"test",
			"owner":		"terratest",
			"roks_version":		4.7,
			"entitled_registry_key":	os.Getenv("CP_ENTITLEMENT"), //pragma: allowlist secret
			"entitled_registry_user_email":	os.Getenv("CP_ENTITLEMENT_EMAIL"),
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	/* url := terraform.Output(t, terraformOptions, "url")
	if len(url) <= 0 {
		t.Fatal("Wrong output")
	}
	fmt.Println("Cloud Pak for Integration Console URL", url)
	user := terraform.Output(t, terraformOptions, "user")
	if len(user) <= 0 {
		t.Fatal("Wrong output")
	}
	fmt.Println("Cloud Pak for Integration Console User ID", user)
	password := terraform.Output(t, terraformOptions, "password") //pragma: allowlist secret
	if len(password) <= 0 {
		t.Fatal("Wrong output")
	}
	fmt.Println("Cloud Pak for Integration Console Password", password)*/
}
