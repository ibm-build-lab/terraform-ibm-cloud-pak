#!/bin/bash
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.db2_namespace)"')"
# Obtains the credentials and endpoints for the installed CP4I Dashboard
results() {
  console_url_address=$1
  nodePort=$2

  # NOTE: The credentials are static and defined by the installer, in the future this
  # may not be the case.
  # username="admin"
  jq -n \
    --arg endpoint "$console_url_address" \
    --arg nodePort "$nodePort" \
    '{ "endpoint": $endpoint, "nodePort": $nodePort }'
  exit 0
}
# POD=$(kubectl get pods -n cpd-meta-ops | grep ibm-cp-data-operator | awk '{print $1}')
# control_plane_log=$(kubectl logs -n cpd-meta-ops $POD | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
# address=$(echo $control_plane_log | sed -n 's#.*\(https*://[^"]*\).*#\1#p')
route=$(get route console -n openshift-console -o yaml | grep routerCanonicalHostname)
nodePort=$(get route console -n openshift-console -o yaml | grep routerCanonicalHostname)
results "${route}" "${nodePort}"