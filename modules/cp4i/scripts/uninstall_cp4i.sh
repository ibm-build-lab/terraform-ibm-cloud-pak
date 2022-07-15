# Uncomment or manually set these variables.
# export API_KEY="******************" #pragma: allowlist secret
# export CLUSTER_ID="****************"
# export NAMESPACE="cp4i"
#ibmcloud login -q --apikey $API_KEY
#ibmcloud ks cluster config -c $CLUSTER_ID --admin

echo "Deleting Resources"
echo "kubectl delete APIConnectCluster -n ${NAMESPACE} --all"
kubectl delete APIConnectCluster -n ${NAMESPACE} --all
echo "kubectl delete Dashboard -n ${NAMESPACE} --all"
kubectl delete Dashboard -n ${NAMESPACE} --all
echo "kubectl delete DataPowerService -n ${NAMESPACE} --all"
kubectl delete DataPowerService -n ${NAMESPACE} --all
echo "kubectl delete DesignerAuthoring -n ${NAMESPACE} --all"
kubectl delete DesignerAuthoring -n ${NAMESPACE} --all
echo "kubectl delete EventStreams -n ${NAMESPACE} --all"
kubectl delete EventStreams -n ${NAMESPACE} --all
echo "kubectl delete QueueManager -n ${NAMESPACE} --all"
kubectl delete QueueManager -n ${NAMESPACE} --all
echo "kubectl delete OperationsDashboard -n ${NAMESPACE} --all"
kubectl delete OperationsDashboard -n ${NAMESPACE} --all
echo "kubectl delete AssetRepository -n ${NAMESPACE} --all"
kubectl delete AssetRepository -n ${NAMESPACE} --all
echo "kubectl delete PlatformNavigator -n ${NAMESPACE} --all"
kubectl delete PlatformNavigator -n ${NAMESPACE} --all
echo "kubectl delete subscription -n ${NAMESPACE} --all"
kubectl delete subscription -n ${NAMESPACE} --all
echo "kubectl delete csv -n ${NAMESPACE} --all"
kubectl delete csv -n ${NAMESPACE} --all
echo "kubectl delete OperatorGroup -n ${NAMESPACE} --all"
kubectl delete OperatorGroup -n ${NAMESPACE} --all
echo "kubectl delete jobs -n cp4i --all"
kubectl delete jobs -n cp4i --all
echo "kubectl delete pods -n cp4i --all"
kubectl delete pods -n cp4i --all
echo "kubectl delete ConfigMap couchdb-release redis-release -n ${NAMESPACE}"
kubectl delete ConfigMap couchdb-release redis-release -n ${NAMESPACE}
echo "kubectl delete catalogsource ibm-operator-catalog -n openshift-marketplace"
kubectl delete catalogsource ibm-operator-catalog -n openshift-marketplace
echo "kubectl delete pv ibm-common-services/mongodbdir-icp-mongodb-0"
kubectl delete pv mongodbdir-icp-mongodb-0
echo "kubectl delete secret ibm-entitlement-key -n default" #pragma: allowlist secret
kubectl delete secret ibm-entitlement-key -n default #pragma: allowlist secret
echo "kubectl delete secret ibm-entitlement-key -n openshift-operators" #pragma: allowlist secret
kubectl delete secret ibm-entitlement-key -n openshift-operators #pragma: allowlist secret
echo "kubectl delete secret ibm-entitlement-key -n ${NAMESPACE}" #pragma: allowlist secret
kubectl delete secret ibm-entitlement-key -n ${NAMESPACE} #pragma: allowlist secret
echo "kubectl delete namespace ${NAMESPACE}"
kubectl delete namespace ${NAMESPACE}
# remove kubernetes from finalizer
#kubectl get namespace ${NAMESPACE} -o json | jq 'del(.spec.finalizers[] | select(. == "kubernetes"))' > ${NAMESPACE}.json
#kubectl replace --raw "/api/v1/namespaces/${NAMESPACE}/finalize" -f ./${NAMESPACE}.json
#kubectl delete namespace ${NAMESPACE}
