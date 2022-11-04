#!/bin/bash

eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.namespace)"')"

# Obtains the credentials and endpoints for the installed CP4I Dashboard
results() {
  console_url_address=$1
  password=$2
  username=$3

  # NOTE: The credentials are static and defined by the installer, in the future this
  # may not be the case.
  # username="admin"

  jq -n \
    --arg endpoint "$console_url_address" \
    --arg username "$username" \
    --arg password "$password" \
    '{ "endpoint": $endpoint, "username": $username, "password": $password }'

  exit 0
}

route=$(kubectl get route -n ${NAMESPACE} evtmanager-ibm-hdm-common-ui -o jsonpath='{.spec.host}')
pass=$(kubectl -n ${NAMESPACE} get secret evtmanager-icpadmin-secret -o jsonpath='{.data.ICP_ADMIN_PASSWORD}' | base64 -d && echo)
user="icpadmin"


results "${route}" "${pass}" "${user}"
