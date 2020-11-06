#!/bin/bash

NAMESPACE="ibm-common-services"

# Get the KUBECONFIG variable from STDIN
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig)"')"

credentials=$(kubectl get secret platform-auth-idp-credentials -n ${NAMESPACE} -o jsonpath='{.data}')
username=$(echo $credentials | jq -r .admin_username | base64 -d)
password=$(echo $credentials | jq -r .admin_password | base64 -d)
host=$(kubectl get route cp-console -n ${NAMESPACE} -o jsonpath='{.spec.host}')

jq -n \
  --arg username "$username" \
  --arg password "$password" \
  --arg host "$host" \
  '{ "username": $username, "password": $password, "host": $host }'
