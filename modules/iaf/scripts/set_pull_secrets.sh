#!/bin/sh
# Script to set pull secrets and reboot the nodes before IAF can be installed

ibmcloud config --check-version=false
ibmcloud login --apikey ${IC_API_KEY} -r ${REGION} -g ${RESOURCE_GROUP} -q
ibmcloud ks cluster config -c ${IAF_CLUSTER} --admin

echo "Setting Pull Secret"
# Extract secret
kubectl get secret/pull-secret -n openshift-config -o json > pull-secret.json
cat pull-secret.json | jq '.data[".dockerconfigjson"]' | sed -e 's/"//g' | base64 -d > dockerconfigjson
#  echo "dockerconfigjson: "
#  cat dockerconfigjson
#  echo ""

# Append to secret
API_KEY=$(printf "%s:%s" $IAF_ENTITLED_REGISTRY_USER $IAF_ENTITLED_REGISTRY_KEY | base64 | tr -d '[:space:]')
NEW_SECRET_VALUE=$(jq --arg apikey ${API_KEY} --arg registry "${IAF_ENTITLED_REGISTRY}" '.auths += {($registry): {"auth":$apikey}}' dockerconfigjson | base64)
#  echo "NEW_SECRET_VALUE: " $NEW_SECRET_VALUE
#  echo ""
jq --arg value "$NEW_SECRET_VALUE" '.data[".dockerconfigjson"] = $value' pull-secret.json > pull-secret-new.json
#  echo "pull-secret-new.json: "
#  cat pull-secret-new.json

# Update Secret
kubectl apply -f pull-secret-new.json
rm dockerconfigjson pull-secret-new.json pull-secret.json

worker_count=0
ibmcloud ks workers --cluster ${IAF_CLUSTER}

echo "Rebooting workers, could take up to 60 minutes"
$IAF_CLUSTER_ON_VPC ? action=replace : action=reload
[[ $IAF_CLUSTER_ON_VPC == "true" ]] && action=replace || action=reload
for worker in $(ibmcloud ks workers --cluster ${IAF_CLUSTER} | grep kube- | awk '{ print $1 }'); 
do echo "reloading worker";
  ibmcloud ks worker $action --cluster ${IAF_CLUSTER} -w $worker -f; 
  ((worker_count++))
done

echo "Waiting for workers to delete ..."
kubectl get nodes | grep SchedulingDisabled
result=$?
counter=0
while [[ "${result}" -eq 0 ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "Workers did not delete within 60 minutes.  Please investigate"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for workers to delete"
    sleep 180s
    kubectl get nodes | grep SchedulingDisabled
    result=$?
done

# Loop until all workers are in Ready state
result=$(kubectl get nodes | grep " Ready" | awk '{ print $2 }' | wc -l)
counter=0
echo "Waiting for all $worker_count workers to restart"
while [[ $result -lt $worker_count ]]
do
    if [[ $counter -gt 30 ]]; then
        echo "Workers did not reload within 60 minutes.  Please investigate"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for all $worker_count workers to restart"
    sleep 180s
    result=$(kubectl get nodes | grep " Ready" | awk '{ print $2 }' | wc -l)
done

