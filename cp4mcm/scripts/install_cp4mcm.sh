#!/bin/sh

echo "Creating namespace ${MCM_NAMESPACE}"
kubectl create namespace ${MCM_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "Setting valid route to containers registry for IBM Cloud Pak Multicloud Management images"
kubectl patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'

echo "Creating secret from entitlement key"
kubectl create secret docker-registry ibm-management-pull-secret \
  --docker-username=${MCM_ENTITLED_REGISTRY_USER} \
  --docker-password=${MCM_ENTITLED_REGISTRY_KEY} \
  --docker-email=${MCM_ENTITLED_REGISTRY_USER_EMAIL} \
  --docker-server=${MCM_ENTITLED_REGISTRY} \
  --namespace=${MCM_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating the CP4MCM Operator catalog source"
kubectl apply -f -<<EOF
${MCM_CATALOGSOURCE_CONTENT}
EOF

echo "Creating subscription for IBM Management Orchestrator, which creates other subscriptions"
kubectl apply -f ${MCM_SUBSCRIPTION_FILE}

echo "Waiting for Subscription to be ready before install MCM"
while ! kubectl get sub ibm-common-service-operator-stable-v1-opencloud-operators-openshift-marketplace ibm-management-orchestrator operand-deployment-lifecycle-manager-app --namespace openshift-operators; do
  sleep ${MCM_WAIT_SEC};
done

echo "Creating the MCM installation"
kubectl apply -f -<<EOF
${MCM_INSTALLATION_CONTENT}
EOF

echo "Waiting for MCM credentials to be ready"
while ! kubectl get secret platform-auth-idp-credentials --namespace ibm-common-services; do
  sleep ${MCM_WAIT_SEC};
done

echo "Waiting for MCM endpoint to be ready"
while ! kubectl get route cp-console --namespace ibm-common-services; do
  sleep ${MCM_WAIT_SEC};
done
