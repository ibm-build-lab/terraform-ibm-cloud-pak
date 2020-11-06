#!/bin/bash

ICPA_JOB_NAME="icpa-installer"

# Get the KUBECONFIG variable from STDIN
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig)" ICPA_NAMESPACE=\(.namespace)')"

pod=$(kubectl get pods --selector=job-name=${ICPA_JOB_NAME} -n ${ICPA_NAMESPACE} --output=jsonpath='{.items[*].metadata.name}')

result_txt=$(kubectl logs -n ${ICPA_NAMESPACE} $pod | tail -12)

if ! echo $result_txt | grep -q 'Installation complete.'; then echo '{ "error_message": "Installation Failed" }'; exit 1; fi

endpoint_cp4app=$(echo $result_txt | grep 'Please see https' | sed 's|.*Please see https\(.*\) to.*|https\1|')
endpoint_advisor_ui=$(echo $result_txt | grep 'IBM Transformation Advisor UI' | sed 's|.*available at: \(.*cloud\).*|\1|')
endpoint_navigator_ui=$(echo $result_txt | grep 'IBM Application Navigator UI' | sed 's|.*available at: \(.*cloud\).*|\1|')


jq -n \
  --arg endpoint_cp4app "$endpoint_cp4app" \
  --arg endpoint_advisor_ui "$endpoint_advisor_ui" \
  --arg endpoint_navigator_ui "$endpoint_navigator_ui" \
  '{ "endpoint_cp4app": $endpoint_cp4app, "endpoint_advisor_ui": $endpoint_advisor_ui, "endpoint_navigator_ui": $endpoint_navigator_ui }'
