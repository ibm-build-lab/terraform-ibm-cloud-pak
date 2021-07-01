WORKSPACE_NAME 			 ?= cloud-pack-sandbox-$(shell date +'%y-%m-%d')
WORKSPACE_FILE 				= $(CLOUD_PAK_DIR)/workspace.json
WORKSPACE_ID_FILE			= $(CLOUD_PAK_DIR)/.workspace_id
WORKSPACE_OUTPUT_FILE	= $(CLOUD_PAK_DIR)/output.json
BRANCH 								= $(shell git branch --show-current)
ENTITLEMENT_KEY 		?= $(shell cat $(ENTITLEMENT_KEY_FILE))
KC_BASE_DIR 				?= $(CLOUD_PAK_DIR)/.kube
KC_FILE							?= $(KC_BASE_DIR)/config.json

with-schematics: check check-sch var-sch init-sch
	@echo
	@$(ECHO) "$(C_GREEN)Wait until the workspace is created, then execute $(C_YELLOW)make plan-sch$(C_STD)"

## Validations

check-ibmcloud:
	@if ibmcloud --version | grep -q 'ibmcloud version'; then $(ECHO) "$(P) $(OK) ibmcloud"; else $(ECHO) "$(P) $(ERROR) ibmcloud"; exit 1; fi
	@if ibmcloud plugin list | grep -q schematics; then $(ECHO) "$(P) $(OK) schematics plugin"; else $(ECHO) "$(P) $(ERROR) schematics plugin"; exit 1; fi
	@if ibmcloud plugin list | grep -q kubernetes-service; then $(ECHO) "$(P) $(OK) kubernetes-service plugin"; else $(ECHO) "$(P) $(ERROR) kubernetes-service plugin"; exit 1; fi

check-workspace-id:
	@[[ -e $(WORKSPACE_ID_FILE) ]]
	@[[ -n $$(cat $(WORKSPACE_ID_FILE)) ]]

check-sch: check-ibmcloud

## Variables

var-sch:
	@[[ -n $${TF_VAR_entitled_registry_user_email} ]]
	@[[ -n "$(ENTITLEMENT_KEY)" ]]
	@$(ECHO) "$(C_GREEN)Input Variables:$(C_STD)"
	@$(ECHO) "$(P)WORKSPACE_NAME:     $(WORKSPACE_NAME)"
	@$(ECHO) "$(P)PROJECT:            $(TF_VAR_project_name)"
	@$(ECHO) "$(P)OWNER:              $(BY)"
	@$(ECHO) "$(P)CLUSTER_ID:         $${TF_VAR_cluster_id}"
	@$(ECHO) "$(P)ENTITLED_KEY:       $(ENTITLEMENT_KEY)"
	@$(ECHO) "$(P)ENTITLED_KEY_EMAIL: $${TF_VAR_entitled_registry_user_email}"
	@$(ECHO) "$(P)BRANCH:             $(BRANCH)"
	@sed \
	-e "s|{{ BRANCH }}|$(BRANCH)|" \
  -e "s|{{ WORKSPACE_NAME }}|$(WORKSPACE_NAME)|" \
  -e "s|{{ PROJECT }}|$(TF_VAR_project_name)|" \
  -e "s|{{ OWNER }}|$(BY)|" \
	-e "s|{{ ENV }}|sandbox|" \
  -e "s|{{ CLUSTER_ID }}|$${TF_VAR_cluster_id}|" \
  -e "s|{{ ENTITLED_KEY }}|$(ENTITLEMENT_KEY)|" \
  -e "s|{{ ENTITLED_KEY_EMAIL }}|$${TF_VAR_entitled_registry_user_email}|" \
	$(CLOUD_PAK_DIR)/workspace.tmpl.json > $(WORKSPACE_FILE)

## Schematics commands

init-sch: rm-workspace-id
	@id=$$(ibmcloud schematics workspace new --file $(WORKSPACE_FILE) --output json | jq -r '.id'); \
	if [[ -n $$id ]]; then echo $$id > $(WORKSPACE_ID_FILE); \
	$(ECHO) "$(OK) Workspace created (id = $$id)"; else \
	$(ECHO) "$(ERROR) Fail to create Workspace"; fi; \
	$(ECHO) "$(C_GREEN)Check the workspace and validate the input variables in the Web Console $(C_YELLOW)https://cloud.ibm.com/schematics/workspaces/$$(cat $(WORKSPACE_ID_FILE))/details$(C_STD)"

plan-sch: check-workspace-id
	@act_id=$$(ibmcloud schematics plan --id $$(cat $(WORKSPACE_ID_FILE)) --output json | jq -r '.activityid'); \
	if [[ -n $$act_id ]]; then \
		$(ECHO) "$(OK) Planning sucessfully started (activity id = $$act_id)"; else \
		$(ECHO) "$(ERROR) Fail to start the planning"; fi; \
	$(ECHO) "$(C_GREEN)Check the logs in the Web Console $(C_YELLOW)https://cloud.ibm.com/schematics/workspaces/$$(cat $(WORKSPACE_ID_FILE))/log/$${act_id}$(C_STD)"; \
	$(ECHO) "$(C_GREEN)Or executing: $(C_YELLOW)ibmcloud schematics logs --id $$(cat $(WORKSPACE_ID_FILE)) --act-id $${act_id}$(C_STD)"
	@echo
	@$(ECHO) "$(C_GREEN)Wait until the plan is generated, then execute $(C_YELLOW)make apply-sch$(C_STD)"

apply-sch: check-workspace-id
	@act_id=$$(ibmcloud schematics apply --force --id $$(cat $(WORKSPACE_ID_FILE)) --output json | jq -r '.activityid'); \
	if [[ -n $$act_id ]]; then \
		$(ECHO) "$(OK) Plan execution sucessfully started (activity id = $$act_id)"; else \
		$(ECHO) "$(ERROR) Fail to start the plan execution"; fi; \
	$(ECHO) "$(C_GREEN)Check the logs in the Web Console $(C_YELLOW)https://cloud.ibm.com/schematics/workspaces/$$(cat $(WORKSPACE_ID_FILE))/log/$${act_id}$(C_STD)"; \
	$(ECHO) "$(C_GREEN)Or executing: $(C_YELLOW)ibmcloud schematics logs --id $$(cat $(WORKSPACE_ID_FILE)) --act-id $${act_id}$(C_STD)"
	@echo
	@$(ECHO) "$(C_GREEN)Wait until the generated plan is applied, then execute $(C_YELLOW)make output-sch$(C_STD)"
	@$(ECHO) "$(C_GREEN)To destroy the cluster execute $(C_YELLOW)make destroy-sch$(C_STD)"

generate-output-sch: check-workspace-id
	@ibmcloud schematics output --output json --id $$(cat $(WORKSPACE_ID_FILE)) > $(WORKSPACE_OUTPUT_FILE)
	@mkdir -p $(KC_BASE_DIR)
	@id=$$(jq -r '.[].output_values[].cluster_id.value' $(WORKSPACE_OUTPUT_FILE)); \
	ibmcloud ks cluster config --cluster $${id} --admin --output json > $(KC_FILE)
	@jq '.[].output_values[].kubeconfig.value = "$(PWD)/$(KC_FILE)"' $(WORKSPACE_OUTPUT_FILE) > $(WORKSPACE_OUTPUT_FILE).tmp && mv $(WORKSPACE_OUTPUT_FILE).tmp $(WORKSPACE_OUTPUT_FILE)

output-sch: generate-output-sch
	@jq -r '.[].output_values | .[] | to_entries[] | [ .key, .value.value ] | @tsv' $(WORKSPACE_OUTPUT_FILE) | awk -v FS="\t" '{printf "%-16s: %s%s",$$1,$$2,ORS}'

## Tests

check-output-sch:
	@[[ -e $(WORKSPACE_OUTPUT_FILE) ]]

test-sch-kubernetes: check-output-sch
	@kubeconfig=$$(jq -r '.[].output_values[].kubeconfig.value' $(WORKSPACE_OUTPUT_FILE)); \
	if TERM=dumb kubectl cluster-info --kubeconfig=$${kubeconfig} | grep -q 'Kubernetes master is running at';\
		then $(ECHO) "$(P) $(PASS) Kubernetes Cluster Running";\
		else $(ECHO) "$(P) $(FAIL) Kubernetes Cluster is not Running. Endpoint not found"; fi

test-sch-endpoint: check-output-sch
	@if jq -r '.[].output_values[].cluster_endpoint.value' $(WORKSPACE_OUTPUT_FILE) | grep -q 'https://';\
		then $(ECHO) "$(P) $(PASS) Kubernetes Cluster created by Terraform";\
		else $(ECHO) "$(P) $(FAIL) Kubernetes Cluster not ready"; fi

test-sch: generate-output-sch test-sch-endpoint test-sch-kubernetes
	@$(MAKE) -C $(CLOUD_PAK_DIR) test-sch

## Cleanup

destroy-sch: check-workspace-id
	@act_id=$$(ibmcloud schematics destroy --force --id $$(cat $(WORKSPACE_ID_FILE)) --output json | jq -r '.activityid'); \
	if [[ -n $$act_id ]]; then \
		$(ECHO) "$(OK) Resources destruction sucessfully started (activity id = $$act_id)"; else \
		$(ECHO) "$(ERROR) Fail to start the destruction of resources"; fi; \
	$(ECHO) "$(C_GREEN)Check the logs in the Web Console $(C_YELLOW)https://cloud.ibm.com/schematics/workspaces/$$(cat $(WORKSPACE_ID_FILE))/log/$${act_id}$(C_STD)"; \
	$(ECHO) "$(C_GREEN)Or executing: $(C_YELLOW)ibmcloud schematics logs --id $$(cat $(WORKSPACE_ID_FILE)) --act-id $${act_id}$(C_STD)"
	@echo
	@$(ECHO) "$(C_GREEN)Wait until the cluster is destroyed, then you may delete the workspace executing $(C_YELLOW)make delete-sch$(C_STD)"

delete-sch: check-workspace-id
	@ibmcloud schematics workspace delete --force --id $$(cat $(WORKSPACE_ID_FILE))
	@echo
	@$(ECHO) "$(C_GREEN)Now you may clean the directory executing $(C_YELLOW)make clean-sch$(C_STD)"

rm-workspace-id:
	$(RM) $(WORKSPACE_ID_FILE)

clean-sch: rm-workspace-id
	$(RM) $(WORKSPACE_FILE)
	$(RM) $(WORKSPACE_ID_FILE)
	$(RM) $(WORKSPACE_OUTPUT_FILE)
	$(RM) -r $(KC_BASE_DIR)
