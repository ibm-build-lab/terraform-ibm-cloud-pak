#!/bin/sh

echo "=== creating operator group ==="

cat << EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: cp4waiops-operator-group
  namespace: ${NAMESPACE}
spec:
  targetNamespaces:
    - ${NAMESPACE}
EOF

echo "=== installing aiops operator ==="
cat << EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-aiops-orchestrator
  namespace: ${NAMESPACE}
spec:
  channel: v3.2
  installPlanApproval: Automatic
  name: ibm-aiops-orchestrator
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOF

echo "=== checking for successful operator install ==="
# Some type of loop with timer to check for success based on this command:
# kubectl get csv -n <namespace> | grep ibm-aiops-orchestrator

SLEEP_TIME="15"
TIMEOUT_LIMIT=40 # 10min timout
TIMEOUT_COUNT=0

echo "Grabbing csv name"
while true; do
    POD_NAME=`kubectl get csv -n $NAMESPACE | grep ibm-aiops-orchestrator | awk '{print $1}'`
    if [ "$POD_NAME" != "" ]; then
        break
    fi
    echo "Sleeping 5 seconds..."
    sleep 5
done

echo "Found $POD_NAME, grabbing status"

while true; do
    if [ "$TIMEOUT_COUNT" -eq "$TIMEOUT_LIMIT" ]; then
        echo "=== problem installing operator, please check the operator log/events ==="
        exit 1
    fi

    # Checking status of the operator
    STATUS=`kubectl get csv $POD_NAME -n $NAMESPACE --output=json | jq -c -r '.status.phase'`
    echo "Current status: $STATUS"
    if [ "$STATUS" == "Succeeded" ]; then
        break
    fi
  
    echo "Sleeping $SLEEP_TIME seconds..."
    sleep $SLEEP_TIME

    (( TIMEOUT_COUNT++ ))
done

echo "=== operator install successful ==="