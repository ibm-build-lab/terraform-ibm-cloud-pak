default: test-classic

all: fmt test-classic test-kubernetes

fmt:
	@terraform fmt
	@terraform fmt ..

check-api-key:
	@[[ -n $$IC_API_KEY ]]

check-classic-cred: check-api-key
	@[[ -n $$IAAS_CLASSIC_USERNAME && -n $$IAAS_CLASSIC_API_KEY ]]

var-%:
	@echo "owner = \"$(USER)\""		> test.auto.tfvars
	@echo "infra = \"$*\""			 >> test.auto.tfvars
	@terraform fmt test.auto.tfvars

validate:
	@echo "Input Variables:"
	@cat test.auto.tfvars
	terraform fmt -recursive -check ..
	terraform validate ..
	terraform validate .
	terraform plan -lock=false -input=false

init:
	terraform init

test-vpc: check-api-key var-vpc init validate
	terraform apply -auto-approve

test-classic: check-classic-cred var-classic init validate
	terraform apply -auto-approve

test-kubernetes:
	export KUBECONFIG=$$(terraform output config_file_path); \
	kubectl cluster-info; \
	kubectl get namespace terraform-module-is-working

destroy:
	terraform destroy -auto-approve

clean: destroy
	$(RM) test.auto.tfvars
	$(RM) terraform.tfstate*
	$(RM) -r .terraform
	$(RM) -r .kube


