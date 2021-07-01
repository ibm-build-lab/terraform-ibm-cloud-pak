SHELL			= /bin/bash

CP 														?= mcm
CLOUD_PAK											:= $(CP)
CLOUD_PAK_DIR									:= cp4$(CLOUD_PAK)
CLOUD_PAK_SUPPORTED						:= mcm app data
# CLOUD_PAK_SUPPORTED						:= any mcm app data int
ENTITLEMENT_KEY_FILE 					?= $(CLOUD_PAK_DIR)/entitlement.key
BY 														?= $(USER)
TF_VAR_project_name 					?= cloud-pak-$(CLOUD_PAK)

ifeq (,$(filter $(CLOUD_PAK),$(CLOUD_PAK_SUPPORTED)))
$(error variable CP not set correctly. The supported Cloud Pak and correct values for CP are: $(CLOUD_PAK_SUPPORTED))
endif

ifeq (any,$(CLOUD_PAK))
CLOUD_PAK_DIR=cloud-paks
endif

default: with-terraform

include Colors.mk
include Terraform.mk
include Schematics.mk
include Catalog.mk

check-api-key:
	@if [[ -n $$IC_API_KEY ]];\
		then $(ECHO) "$(P) $(OK) IC_API_KEY";\
		else $(ECHO) '$(P) $(ERROR) IC_API_KEY. Execute: make api-key; export IC_API_KEY=$$(jq -r .apikey test/terraform/.terraform_key.json)';  exit 1; fi

check-classic-keys: check-api-key
	@if [[ -n $$IAAS_CLASSIC_USERNAME ]];\
		then $(ECHO) "$(P) $(OK) IAAS_CLASSIC_USERNAME";\
		else $(ECHO) '$(P) $(ERROR) IAAS_CLASSIC_USERNAME. It is your IBM Cloud username or email address';  exit 1; fi
	@if [[ -n $$IAAS_CLASSIC_API_KEY ]];\
		then $(ECHO) "$(P) $(OK) IAAS_CLASSIC_API_KEY";\
		else $(ECHO) '$(P) $(ERROR) IAAS_CLASSIC_API_KEY. Know how to get it from https://cloud.ibm.com/docs/account?topic=account-classic_keys';  exit 1; fi

check-entitlement:
	@if [[ ! -e $(ENTITLEMENT_KEY_FILE) && -e ./entitlement.key ]]; then \
		cp ./entitlement.key $(ENTITLEMENT_KEY_FILE); \
		$(ECHO) "$(P) $(INFO) The entitlement key file was copied to $(ENTITLEMENT_KEY_FILE)"; \
	fi
	@if [[ -e $(ENTITLEMENT_KEY_FILE) && -n "$$(cat $(ENTITLEMENT_KEY_FILE))" ]];\
		then $(ECHO) "$(P) $(OK) Entitlement Key file";\
		else $(ECHO) '$(P) $(ERROR) Entitlement Key file. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, save the key to the file "$(ENTITLEMENT_KEY_FILE)"';  exit 1; fi
	@if [[ -n $$TF_VAR_entitled_registry_user_email ]];\
		then $(ECHO) "$(P) $(OK) TF_VAR_entitled_registry_user_email";\
		else $(ECHO) '$(P) $(ERROR) TF_VAR_entitled_registry_user_email. Export the variable with email address used to get the entitlement key';  exit 1; fi

check: check-classic-keys check-entitlement

fmt:
	terraform fmt -recursive

validate: check init-tf var-tf
	@$(ECHO) "$(C_GREEN)Validating $(C_YELLOW)$(CLOUD_PAK)$(C_STD)"
	@$(ECHO) "$(C_GREEN)Input Variables:$(C_STD)"
	@cat $(MY_TF_VARS_FILE)
	@$(ECHO) "$(C_GREEN)Validating Terraform code format: $(C_STD)"
	cd $(CLOUD_PAK_DIR) && terraform fmt -recursive -check
	@$(ECHO) "$(C_GREEN)Validating Terraform code: $(C_STD)"
	cd $(CLOUD_PAK_DIR) && terraform validate
	@$(ECHO) "$(C_GREEN)Validating $(CLOUD_PAK_DIR) on IBM Cloud $*: $(C_STD)"
	cd $(CLOUD_PAK_DIR) && terraform plan -lock=false -input=false

clean: clean-tf clean-sch

validate-all:
	@for cp in $(CLOUD_PAK_SUPPORTED); do \
		$(MAKE) validate CP=$$cp; \
	done

clean-all:
	@for cp in $(CLOUD_PAK_SUPPORTED); do \
		$(MAKE) clean CP=$$cp; \
	done
