#!/bin/sh

ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
#ibmcloud ks cluster config -c ${MCM_CLUSTER} --admin

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

echo "Creating the Common Services Operator CatalogSource resource"
kubectl apply -f -<<EOF
${MCM_CS_CATALOGSOURCE_CONTENT}
EOF

echo "Creating the Common Services Subscription"
kubectl apply -f ${MCM_CS_SUBSCRIPTION_FILE}

kubectl get CommonService common-service -n ibm-common-services > /dev/null 2>&1
result=$?
counter=0
while [[ "${result}" -ne 0 ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "The CommonService CustomResource was not created within five minutes; please attempt to install the product again."
        exit 1
    fi
    counter=$((counter + 1))
    echo "The CommonService CustomResource has not been created yet; delaying modification"
    sleep ${MCM_WAIT_SEC};
    oc get CommonService common-service -n ibm-common-services > /dev/null 2>&1
    result=$?
done

echo "Modifying CommonService CustomResource"
kubectl apply -f ${MCM_COMMONSERVICE_FILE}

echo "Creating the IBM Management Orchestrator"
kubectl apply -f -<<EOF
${MCM_MGT_CATALOGSOURCE_CONTENT}
EOF

echo "Creating subscription for IBM Management Orchestrator, which creates other subscriptions"
kubectl apply -f ${MCM_MGT_SUBSCRIPTION_FILE}

sleep ${MCM_WAIT_SEC};
sleep ${MCM_WAIT_SEC};

echo "Creating the MCM installation"
kubectl apply -f -<<EOF
${MCM_INSTALLATION_CONTENT}
EOF

echo "Waiting for MCM credentials to be ready"
#while ! kubectl get secret platform-auth-idp-credentials --namespace ibm-common-services; do
#  sleep ${MCM_WAIT_SEC};
#done
kubectl get secret platform-auth-idp-credentials --namespace ibm-common-services
result=$?
counter=0
while [[ "${result}" -ne 0 ]]
do
    if [[ $counter -gt 60 ]]; then
        echo "MCM Installation did not create successfully within 30 minutes; please attempt to install the product again."
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for MCM credentials to be ready."
    sleep ${MCM_WAIT_SEC};
    kubectl get secret platform-auth-idp-credentials --namespace ibm-common-services > /dev/null 2>&1
    result=$?
done

echo "Waiting for MCM endpoint to be ready"
while ! kubectl get route cp-console --namespace ibm-common-services; do
  sleep ${MCM_WAIT_SEC};
done
