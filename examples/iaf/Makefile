SHELL			= /bin/bash

WORKSPACE_OUTPUT_FILE := output.json

include ../Colors.mk

var-tf:
	@echo

define test-namespace
	@if kubectl get namespace $(1) --kubeconfig=$(2) > /dev/null; \
		then $(ECHO) "$(P) $(PASS) IAF Namespace Exists";\
		else $(ECHO) "$(P) $(FAIL) IAF Namespace not found"; exit 1; \
	fi
endef

test-tf:
	$(call test-namespace,$$(terraform output iaf_namespace),$$(terraform output kubeconfig))

test-sch:
	@[[ -e $(WORKSPACE_OUTPUT_FILE) ]]
	$(call test-namespace,$$(cat $(WORKSPACE_OUTPUT_FILE) | jq -r '.[].output_values[].iaf_namespace.value'),$$(cat $(WORKSPACE_OUTPUT_FILE) | jq -r '.[].output_values[].kubeconfig.value'))
