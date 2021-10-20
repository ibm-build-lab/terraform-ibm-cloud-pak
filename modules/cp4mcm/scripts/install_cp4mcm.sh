#!/bin/sh

echo ${KUBECONFIG}
ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
ibmcloud ks cluster config -c ${MCM_CLUSTER} --admin

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

echo "Creating the Common Services Operator CatalogSource resource ${MCM_CS_CATALOGSOURCE_CONTENT}"
kubectl apply -f -<<EOF
${MCM_CS_CATALOGSOURCE_CONTENT}
EOF

echo "Creating the Common Services Subscription"
cat ${MCM_CS_SUBSCRIPTION_FILE}
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
cat ${MCM_COMMONSERVICE_FILE}
kubectl apply -f ${MCM_COMMONSERVICE_FILE}

echo "Creating the IBM Management Orchestrator ${MCM_MGT_CATALOGSOURCE_CONTENT}"
kubectl apply -f -<<EOF
${MCM_MGT_CATALOGSOURCE_CONTENT}
EOF

echo "Creating subscription for IBM Management Orchestrator, which creates other subscriptions"
cat ${MCM_MGT_SUBSCRIPTION_FILE}
kubectl apply -f ${MCM_MGT_SUBSCRIPTION_FILE}

sleep ${MCM_WAIT_SEC};
sleep ${MCM_WAIT_SEC};

echo "Creating the MCM installation ${MCM_INSTALLATION_CONTENT}"
kubectl apply -f -<<EOF
${MCM_INSTALLATION_CONTENT}
EOF

echo "Waiting for MCM credentials to be ready. NOTE: you will see an error until credentials are successfully retrieved."
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

echo "Waiting for MCM endpoint to be ready. NOTE: you will see an error until endpoint is successfully retrieved."
while ! kubectl get route cp-console --namespace ibm-common-services; do
  sleep ${MCM_WAIT_SEC};
done

echo "Cloud Pak for MCM has been installed with the default configuration for all requested modules."
echo "For advanced configuration, please refer to https://www.ibm.com/docs/en/cloud-paks/cp-management/2.3.x?topic=installation-configuration."
echo "For post installation tasks, please refer to https://www.ibm.com/docs/en/cloud-paks/cp-management/2.3.x?topic=installation-post-tasks."
echo "To complete set up for Notary Service pods, please refer to https://www.ibm.com/docs/en/cloud-paks/cp-management/2.3.x?topic=operands-notary-service"
