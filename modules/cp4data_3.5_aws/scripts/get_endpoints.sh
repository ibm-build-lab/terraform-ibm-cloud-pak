#!/bin/bash

# Obtains the credentials and endpoints for the installed CP4D control plane
results() {
  console_url_address=$1
  
  # NOTE: The credentials are statics and defined by the installer, in the future this
  # may not be the case.
  username="admin"
  password="password"

  # echo "[INFO] Please update your username and password within the CPD console as soon as possible."

  jq -n \
    --arg endpoint "$console_url_address" \
    --arg username "$username" \
    --arg password "$password" \
    '{ "endpoint": $endpoint, "username": $username, "password": $password }'

  exit 0
}

POD=$(kubectl get pods -n cpd-meta-ops | grep ibm-cp-data-operator | awk '{print $1}')
control_plane_log=$(kubectl logs -n cpd-meta-ops $POD | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
address=$(echo $control_plane_log | sed -n 's#.*\(https*://[^"]*\).*#\1#p')

results "${address}"
