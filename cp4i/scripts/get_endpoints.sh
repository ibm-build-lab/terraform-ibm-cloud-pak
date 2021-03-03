#!/bin/bash

# This currently doesnt do anything
JOB_NAME="cloud-installer"

# Get the KUBECONFIG & NAMESPACE variable from STDIN
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

results() {
  address=$1
  error_message=$2

  if [[ -z $error_message ]]; then
    endpoint="https://$address"
    # The credentials are statics and defined by the installer, in the future this
    # may not be the case.
    username="admin"
    password="password"
  fi


  jq -n \
    --arg endpoint "$endpoint" \
    --arg username "$username" \
    --arg password "$password" \
    --arg error_message "$error_message" \
    '{ "endpoint": $endpoint, "username": $username, "password": $password, "error_message": $error_message }'

  exit 0
}

pod=$(kubectl get pods --selector=job-name=${JOB_NAME} -n ${NAMESPACE} --output=jsonpath='{.items[*].metadata.name}')

if [[ -z $pod ]]; then
  results "" "failed to get the output data, the job installer pod was not found"
fi

result_txt=$(kubectl logs -n ${NAMESPACE} $pod | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
if ! echo $result_txt | grep -q 'Installation of assembly lite is successfully completed'; then
  results "" "a successful installation was not found from the logs"
fi

if [[ -z $address ]]; then
  results "" "failed to get the endpoint address from the logs"
fi
address=$(echo $result_txt | sed 's|.*Access Cloud Pak for Data console using the address: \(.*\) .*|\1|')

results "$address" ""
