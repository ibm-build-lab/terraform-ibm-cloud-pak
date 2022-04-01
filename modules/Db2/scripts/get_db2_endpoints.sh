#!/bin/bash
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.db2_namespace)"')"
K8s_CMD=kubectl

echo
# Obtains the credentials and endpoints for the installed CP4BA Dashboard
results() {
  db2_host_address=$1
  nodePort=$2
  jq -n \
    --arg endpoint "$db2_host_address" \
    --arg nodePort "$nodePort" \
    '{ "endpoint": $endpoint, "nodePort": $nodePort }'
  exit 0
}

echo "****************************************************************************"
echo "********* USE THE FOLLOWING DB2 ENDPOINTS TO ACCESS THE DATABASE!!! ********"
echo "****************************************************************************"
echo
route=$(${K8s_CMD} get route console -n openshift-console -o yaml | grep routerCanonicalHostname | cut -d ":" -f2)
nodePort=$(${K8s_CMD} get svc -n $NAMESPACE c-db2ucluster-db2u-engn-svc -o json | grep nodePort | cut -d ":" -f2)
results "${route}" "${nodePort}"