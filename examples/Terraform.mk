KC_BASE_DIR 		?= $(CLOUD_PAK_DIR)/.kube
MY_TF_VARS_FILE  = $(CLOUD_PAK_DIR)/my_variables.auto.tfvars
TF_STATE_FILE		 = $(CLOUD_PAK_DIR)/terraform.tfstate

with-terraform: check init-tf var-tf apply-tf test-tf

## Terraform commands

init-tf:
	cd $(CLOUD_PAK_DIR) && terraform init -input=false

apply-tf:
	cd $(CLOUD_PAK_DIR) && terraform apply -auto-approve

output-tf:
	terraform output -state=$(TF_STATE_FILE)

## Variables

var-tf:
	@[[ -n $$TF_VAR_entitled_registry_user_email ]]
	@echo "owner = \"$(BY)\"" > $(MY_TF_VARS_FILE)
	@[[ -z $$TF_VAR_project_name   ]] || echo "project_name   = \"$$TF_VAR_project_name\""	>> $(MY_TF_VARS_FILE)
	@[[ -z $$TF_VAR_cluster_id     ]] || echo "cluster_id     = \"$$TF_VAR_cluster_id\""		>> $(MY_TF_VARS_FILE)
	@echo "entitled_registry_user_email = \"$$TF_VAR_entitled_registry_user_email\""				>> $(MY_TF_VARS_FILE)
	@$(MAKE) -C $(CLOUD_PAK_DIR) var-tf
	@terraform fmt $(MY_TF_VARS_FILE)

## Tests

test-tf-kubernetes:
	@if TERM=dumb kubectl cluster-info --kubeconfig=$$(terraform output -state=$(TF_STATE_FILE) kubeconfig) | grep -q 'Kubernetes master is running at';\
		then $(ECHO) "$(P) $(PASS) Kubernetes Cluster created by Terraform";\
		else $(ECHO) "$(P) $(FAIL) Kubernetes Cluster not ready"; exit 1; fi

test-tf-endpoint:
	@if terraform output -state=$(TF_STATE_FILE) cluster_endpoint | grep -q 'https://';\
		then $(ECHO) "$(P) $(PASS) Kubernetes Cluster Running";\
		else $(ECHO) "$(P) $(FAIL) Kubernetes Cluster is not Running. Endpoint not found"; fi

test-tf: test-tf-kubernetes test-tf-endpoint
	@$(MAKE) -C $(CLOUD_PAK_DIR) test-tf

## Cleanup

destroy-tf:
	cd $(CLOUD_PAK_DIR) && terraform destroy -auto-approve

clean-tf:
	$(RM) $(MY_TF_VARS_FILE)
	$(RM) -r $(CLOUD_PAK_DIR)/.terraform
	$(RM) $(CLOUD_PAK_DIR)/terraform.tfstate*
	$(RM) -r $(KC_BASE_DIR)
