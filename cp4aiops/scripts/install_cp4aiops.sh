#!/bin/sh

NAMESPACE=${NAMESPACE:-aiops}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

# Create custom namespace
echo "Creating namespace ${NAMESPACE}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

create_secret() {
  secret_name=$1
  namespace=$2
  link=$3

  echo "Creating secret ${secret_name} on ${namespace} from entitlement key"
  oc create secret docker-registry ${secret_name} \
    --docker-server=${DOCKER_REGISTRY} \
    --docker-username=${DOCKER_USERNAME} \
    --docker-password=${DOCKER_REGISTRY_PASS} \
    --docker-email=${DOCKER_USER_EMAIL} \
    --namespace=${namespace}
}

create_secret ibm-entitlement-key "${NAMESPACE}"


# Configure a network policy for the IBM Cloud Pak for Watson AIOps routes
echo "Configuring the network policy for CP4AIPS routes"
oc get ingresscontroller default -n openshift-ingress-operator -o yaml
oc patch namespace default --type=json -p '[{"op":"add","path":"/metadata/labels","value":{"network.openshift.io/policy-group":"ingress"}}]'


# Configure a network policy for traffic between the Operator Lifecycle Manager and the CatalogSource service
echo "Configuring network policy for traffic between Operator Lifecycle Manager and CatalogSource service."

cat << EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-egress-and-ingress
  namespace: ${NAMESPACE}
spec:
  egress:
  - {}
  ingress:
  - {}
  podSelector: {}
  policyTypes:
  - Egress
  - Ingress
EOF


echo "Adding IBM Cloud Pak for Watson AIOps Orchestrator CatalogSource"

cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-aiops-catalog
  namespace: openshift-marketplace
spec:
  address: ibm-aiops-catalog.openshift-marketplace:50051
  displayName: IBM AIOps Catalog
  publisher: IBM
  sourceType: grpc
  image: icr.io/cpopen/aiops-orchestrator-catalog:3.1-latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

echo "Adding IBM Operators CatalogSource"

cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: ibm-operator-catalog 
  publisher: IBM Content
  sourceType: grpc
  image: docker.io/ibmcom/ibm-operator-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

echo "Adding IBM Common Services CatalogSource"
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: opencloud-operators
  namespace: openshift-marketplace
spec:
  displayName: IBMCS Operators
  publisher: IBM
  sourceType: grpc
  image: docker.io/ibmcom/ibm-common-service-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

echo "Sleeping 1 minutes for catalog services"
sleep 60

echo "Applying CP4WAIOPS subscription"
echo "${CP4WAIOPS}" | oc apply -f -


echo "Waiting 5 minutes for AIOps Operator to install..."
sleep 300

# TODO:
# Potentially pull this out and put it into the TF script instead.
if ${ON_VPC}; then
  storage_class="portworx-fs"
  storage_block_class="portworx-aiops"
else
  storage_class="ibmc-file-gold-gid"
  storage_block_class="ibmc-file-gold-gid"
fi
AIOPS_SERVICE=`sed -e "s/NAMESPACE/${NAMESPACE}/g" -e "s/STORAGE_CLASS/${storage_class}/g" -e "s/STORAGE_BLOCK_CLASS/${storage_block_class}/g" ../templates/cp-aiops-service.yaml`
echo "Deploying Watson AIOPS Service ${AIOPS_SERVICE}"
sed -e "s/NAMESPACE/${NAMESPACE}/g" -e "s/STORAGE_CLASS/${storage_class}/g" -e "s/STORAGE_BLOCK_CLASS/${storage_block_class}/g" ../templates/cp-aiops-service.yaml | oc -n ${NAMESPACE} apply -f -


SLEEP_TIME="60"
RUN_LIMIT=200
i=0

count = 0
while true; do
  if ! STATUS_LONG=$(oc -n ${NAMESPACE} get installation.orchestrator.aiops.ibm.com ibm-cp-watson-aiops --output=json | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
 
  STATUS=$(echo $STATUS_LONG | jq -c -r '.locations')
  if [ $STATUS != "{}" ]; then
    break
  fi
  
  echo "Sleeping $SLEEP_TIME seconds..."
  sleep $SLEEP_TIME
  
  (( i++ ))
  if [ "$i" -eq "$RUN_LIMIT" ]; then
    echo 'Timed out'
    exit 1
  fi
done

echo '=== Installation Complete ==='