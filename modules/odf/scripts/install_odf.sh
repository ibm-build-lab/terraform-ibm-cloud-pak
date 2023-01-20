#!/bin/sh

ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY} 
ibmcloud ks cluster config -c ${CLUSTER} --admin

# Retrieve the openshift cluster version
ROKS_VERSION=`kubectl get clusterversion -o jsonpath='{.items[].status.history[].version}{"\n"}'`
# Round the number down to 0 (e.g. 4.7.40 to 4.7.0)
ROKS_VERSION="${ROKS_VERSION%.*}.0"

ibmcloud ks cluster addon enable openshift-data-foundation -c ${CLUSTER} --version ${ROKS_VERSION} --param "odfDeploy=false"

ibmcloud ks cluster addon ls -c ${CLUSTER} |  grep openshift-data-foundation | grep "Addon Ready"
result=$?
counter=0
while [[ "${result}" -ne 0 ]]
do
    if [[ $counter -gt 20 ]]; then
    echo "Timed out waiting for ODF to be enabled"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for ODF to be enabled"
    sleep 60;
    ibmcloud ks cluster addon ls -c ${CLUSTER} |  grep openshift-data-foundation | grep "Addon Ready"
    result=$?
done

echo "Creating Storage Cluster Custom Resource"
echo ${ODF_CR_CONTENT}
kubectl apply -f -<<EOF
${ODF_CR_CONTENT}
EOF

