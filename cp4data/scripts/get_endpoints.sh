#!/bin/bash

JOB_NAME="cloud-installer"

# Get the KUBECONFIG & NAMESPACE variable from STDIN
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

pod=$(kubectl get pods --selector=job-name=${JOB_NAME} -n ${NAMESPACE} --output=jsonpath='{.items[*].metadata.name}')

result_txt=$(kubectl logs -n ${NAMESPACE} $pod | tail -12)

if ! echo $result_txt | grep -q 'Installation of assembly lite is successfully completed'; then
  echo '{ "error_message": "Installation Failed" }'; exit 1;
fi

address=$(echo $result_txt | grep -A1 'Access Cloud Pak for Data console using the address' | tail -1)


# The credentials are statics and defined by the installer, in the future this
# may not be the case.
jq -n \
  --arg endpoint "https://$address" \
  '{ "endpoint": $endpoint, "username": "admin", "password": "password" }'
