#!/bin/bash
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) NAMESPACE=\(.db2_namespace)"')"

echo

#NAMESPACE=ibm-db2
K8s_CMD=kubectl
echo
# Obtains the credentials and endpoints for the installed CP4BA Dashboard
results() {
  db2_host_address=$1
  nodePort=$2
  jq -n \
    --arg endpoint "$db2_host_address" \
    --arg nodePort "$nodePort" \
    --arg db2_pod_name "$db2_pod_name" \
    '{ "endpoint": $endpoint, "nodePort": $nodePort, "db2_pod_name": $db2_pod_name }'
  exit 0
}

echo
route=$(${K8s_CMD} get route console -n openshift-console -o yaml | grep routerCanonicalHostname | cut -d ":" -f2)
db2_pod_name=$(${K8s_CMD} get pods -n $NAMESPACE | grep db2u-0 | grep Running | awk '{print $1}')
ip_address=$(${K8s_CMD} get pod -n $NAMESPACE $db2_pod_name -o yaml | grep nodeName | cut -d ":" -f2)
nodePort=$(${K8s_CMD} get svc -n $NAMESPACE c-db2ucluster-db2u-engn-svc -o yaml | grep nodePort | cut -d ":" -f2)
results "${route}" "${db2_pod_name}" "${ip_address}" "${nodePort}"

