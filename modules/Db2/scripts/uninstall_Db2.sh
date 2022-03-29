# Uncomment or manually set these variables.
# export API_KEY="******************" //pragma: allowlist secret
# export CLUSTER_ID="****************"
# export NAMESPACE="cp4i"

ibmcloud login -q -apikey "${API_KEY}"
ibmcloud ks cluster config -c "${CLUSTER_ID}" --admin

echo "Deleting Resources"
kubectl delete APIConnectCluster -n "${DB2_PROJECT_NAME}" --all
kubectl delete Dashboard -n "${DB2_PROJECT_NAME}" --all
kubectl delete DataPowerService -n "${DB2_PROJECT_NAME}" --all
kubectl delete DesignerAuthoring -n "${DB2_PROJECT_NAME}" --all
kubectl delete EventStreams -n "${DB2_PROJECT_NAME}" --all
kubectl delete QueueManager -n "${DB2_PROJECT_NAME}" --all
kubectl delete OperationsDashboard -n "${DB2_PROJECT_NAME}" --all
kubectl delete AssetRepository -n "${DB2_PROJECT_NAME}" --all
kubectl delete PlatformNavigator -n "${DB2_PROJECT_NAME}" --all
kubectl delete subscription -n "${DB2_PROJECT_NAME}" --all
kubectl delete csv -n "${DB2_PROJECT_NAME}" --all
kubectl delete OperatorGroup -n "${DB2_PROJECT_NAME}" --all
kubectl delete jobs -n cp4i --all
kubectl delete pods -n cp4i --all
kubectl delete ConfigMap couchdb-release redis-release -n "${DB2_PROJECT_NAME}"
kubectl delete catalogsource ibm-operator-catalog -n openshift-marketplace
kubectl delete pv ibm-common-services/mongodbdir-icp-mongodb-0
kubectl delete secret ibm-entitlement-key -n default
kubectl delete secret ibm-entitlement-key -n openshift-operators
kubectl delete secret ibm-entitlement-key -n "${DB2_PROJECT_NAME}"
kubectl delete namespace "${DB2_PROJECT_NAME}"
# remove kubernetes from finalizer
#kubectl get namespace ${NAMESPACE} -o json | jq 'del(.spec.finalizers[] | select(. == "kubernetes"))' > ${NAMESPACE}.json
#kubectl replace --raw "/api/v1/namespaces/${NAMESPACE}/finalize" -f ./${NAMESPACE}.json
#kubectl delete namespace ${NAMESPACE}