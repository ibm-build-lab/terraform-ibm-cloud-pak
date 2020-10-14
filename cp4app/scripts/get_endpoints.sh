#!/bin/bash

# Get the KUBECONFIG variable from STDIN...
#   ... this option requires JQ installed:
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig)"')"
#   ... this option requires Python installed:
# export KUBECONFIG=$(python -c "import json,sys;obj=json.load(sys.stdin);print obj['kubeconfig'];")

pod=$(kubectl get pods --selector=job-name=icpa-installer -n icpa-installer --output=jsonpath='{.items[*].metadata.name}')

result_txt=$(kubectl logs -n icpa-installer $pod | tail -12)

if ! echo $result_txt | grep -q 'Installation complete.'; then echo '{ "error_message": "Installation Failed" }'; exit 1; fi

cp4app_endpoint=$(echo $result_txt | grep 'Please see https' | sed 's|.*Please see https\(.*\) to.*|https\1|')
advisorui_endpoint=$(echo $result_txt | grep 'IBM Transformation Advisor UI' | sed 's|.*available at: \(.*cloud\).*|\1|')
navigatorui_endpoint=$(echo $result_txt | grep 'IBM Application Navigator UI' | sed 's|.*available at: \(.*cloud\).*|\1|')

cat << EOM
{
  "endpoint_cp4app": "${cp4app_endpoint}",
  "endpoint_advisor_ui": "${advisorui_endpoint}",
  "endpoint_navigator_ui": "${navigatorui_endpoint}"
}
EOM
