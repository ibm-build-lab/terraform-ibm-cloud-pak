CONFIG_DIR 			 = .kube/config
OUTPUT_DIR 			 = rendered_files
TEST_TF_VAR_FILE = test.auto.tfvars

default: test-classic

all: fmt test-classic test-kubernetes

fmt:
	@terraform fmt
	@terraform fmt ..

check-api-key:
	@[[ -n $$IC_API_KEY ]]

check-classic-cred: check-api-key
	@[[ -n $$IAAS_CLASSIC_USERNAME && -n $$IAAS_CLASSIC_API_KEY ]]

# 1. Create a ROKS cluster get the ID and export it in the variable TF_VAR_cluster_id
# 2. (Optional) Export the variable TF_VAR_resource_group with the resource group where the cluster is. This step is optional if the resource group is 'default'
# Like this:
# 		export TF_VAR_cluster_id=btvlh6bd0di5v70fhqn0
# 		export TF_VAR_resource_group=cloud-pak-testing
var-%:
	@[[ -n $$TF_VAR_cluster_id ]]
	@echo "infra = \"$*\""												> $(TEST_TF_VAR_FILE)
	@echo "config_dir = \"$(CONFIG_DIR)\"" 				>> $(TEST_TF_VAR_FILE)
	@echo "cluster_id = \"$$TF_VAR_cluster_id\"" 	>> $(TEST_TF_VAR_FILE)
	@[[ -z $$TF_VAR_resource_group ]] || echo "resource_group = \"$$TF_VAR_resource_group\""  >> $(TEST_TF_VAR_FILE)
	@terraform fmt $(TEST_TF_VAR_FILE)

validate:
	@echo "Input Variables:"
	@cat $(TEST_TF_VAR_FILE)
	terraform fmt -recursive -check ..
	terraform validate ..
	terraform validate .
	terraform plan -lock=false -input=false

init:
	mkdir -p $(CONFIG_DIR)
	mkdir -p $(OUTPUT_DIR)
	terraform init

test-vpc: check-api-key check-entitlement var-vpc init validate
	terraform apply -auto-approve

test-classic: check-classic-cred check-entitlement var-classic init validate
	terraform apply -auto-approve

test-kubernetes:
	export KUBECONFIG=$$(terraform output config_file_path); \
	kubectl cluster-info; \
	kubectl get namespace $(terraform output namespace)

test-mcm:
	@kubectl get namespace $$(terraform output namespace) --kubeconfig=$$(terraform output config_file_path) > /dev/null
	@[[ -n $$(terraform output endpoint) ]]

destroy:
	terraform destroy -auto-approve

clean: destroy
	$(RM) $(TEST_TF_VAR_FILE)
	$(RM) terraform.tfstate*
	$(RM) -r .terraform
	$(RM) -r .kube
	$(RM) -r $(OUTPUT_DIR)
