#!/bin/bash

NAMESPACE="ibm-common-services"

# Get the KUBECONFIG variable from STDIN
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig)"')"

host=$(kubectl get route cp-console -n ${NAMESPACE} -o jsonpath='{.spec.host}')
password=$(kubectl get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_password' | base64 -d)
username=$(kubectl get secret -n ibm-common-services platform-auth-idp-credentials -o json | jq -r '.data.admin_username' | base64 -d)

jq -n \
  --arg username "$username" \
  --arg password "$password" \
  --arg host "$host" \
  '{ "username": $username, "password": $password, "host": $host }'
