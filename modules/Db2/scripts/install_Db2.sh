#!/bin/bash
# set -x
###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2021. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################

echo
echo
echo "*********************************************************************************"
echo "************************** Installing DB2 Module ... ****************************"
echo "*********************************************************************************"


CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

C_DB2UCLUSTER_DB2U="c-db2ucluster-db2u"
C_DB2UCLUSTER_INSTDB="c-db2ucluster-instdb"
SUBCRIPTION_NAME="db2u-operator"


echo
echo "Creating the Security Context Constraints Requirements ..."
kubectl --validate=false apply -f -<<EOF
${SECURITY_CONTEXT_FILE_CONTENT}
EOF
echo
sleep 5

echo
echo "Creating Cluster Role ..."
kubectl apply -f "${DB2_CR_FILE}"
sleep 2

echo
echo "Creating project ${DB2_PROJECT_NAME}..."
kubectl create namespace "${DB2_PROJECT_NAME}"
kubectl get ns "${DB2_PROJECT_NAME}"

echo

echo "Docker username: ${DOCKER_USERNAME}"
kubectl create secret docker-registry ibm-registry --docker-server="${DOCKER_SERVER}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-email="${ENTITLEMENT_REGISTRY_USER_EMAIL}" --namespace="${DB2_PROJECT_NAME}"
sleep 10
echo
kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
echo
kubectl patch storageclass "${DB2_STORAGE_CLASS}" -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
echo


echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(kubectl get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; kubectl get secret ibm-registry -n "${DB2_PROJECT_NAME}" --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
echo
kubectl set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo
echo "Installing the IBM Operator Catalog..."
cat "${DB2_OPERATOR_CATALOG_FILE}"
kubectl apply -f "${DB2_OPERATOR_CATALOG_FILE}"
echo

echo "Docker username: ${DOCKER_USERNAME}"
kubectl create secret docker-registry ibm-db2-registry --docker-server="${DOCKER_SERVER}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-email="${ENTITLEMENT_REGISTRY_USER_EMAIL}" --namespace="${DB2_PROJECT_NAME}"
echo


echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(kubectl get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; kubectl get secret ibm-db2-registry -n "${DB2_PROJECT_NAME}" --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged


echo
kubectl edit secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo
if kubectl get catalogsource -n openshift-marketplace | grep ibm-operator-catalog ; then
        echo "Found ibm operator catalog source"
else
    kubectl apply -f "${DB2_OPERATOR_CATALOG_FILE}"
    if [ $? -eq 0 ]; then
      echo "IBM Operator Catalog source created!"
    else
      echo "Generic Operator catalog source creation failed"
      exit 1
    fi
fi

maxRetry=20
for ((retry=0;retry<="${maxRetry}";retry++)); do
  echo "Waiting for Db2u Operator Catalog pod initialization"

  isReady=$(kubectl get pod -n openshift-marketplace --no-headers | grep ibm-operator-catalog | grep "Running")
  if [[ -z $isReady ]]; then
    if [[ $retry -eq "${maxRetry}" ]]; then
      echo "Timeout Waiting for  Db2u Operator Catalog pod to start"
      echo -e "Please, debug the installation of the Db2u operator. Exiting..."
      exit 1
    else
      sleep 5
      continue
    fi
  else
    echo "Db2u Operator Catalog is running $isReady"
    echo -e "Installation of the Db2u operator succeeded."
    break
  fi
done
echo

## Creating DB2 Operator Group
echo "Creating Operator Group object for DB2 Operator ..."
kubectl apply -f -<<EOF
${DB2_OPERATOR_GROUP_CONTENT}
EOF
echo

sleep 60

###### Create subscription to Db2 Operator
echo -e "\x1B[1m Creating Subscription object for DB2 Operator ... \x1B[0m"
kubectl apply -f -<<EOF
${DB2_SUBSCRIPTION_CONTENT}
EOF
echo

sleep 100

waiting_time=45
echo
echo "Waiting up to ${waiting_time} minutes for DB2 Operator install plan to be generated in $DB2_PROJECT_NAME"
date

echo


function wait_for_operator_to_install_successfully {
  local waiting_time=45
  local max_waiting_time=$(( 60 * $waiting_time))
  local current_time=0
  local CSV_STATUS=""

  while [ $current_time -lt $max_waiting_time ]
  do
    CSV_STATUS=$(kubectl get csv -n "${DB2_PROJECT_NAME}" | grep db2u-operator.v1.1 | grep Succeeded | cat)
    if [ ! -z "$CSV_STATUS" ]
    then
      break
    fi
    sleep 10
    current_time=$(( $current_time + 10 ))
  done

  echo "$CSV_STATUS"
}


function wait_for_install_plan {
  local timeToWait=45
  local max_waiting_time=$(( 60 * ${timeToWait}))
  local current_time=0
  local INSTALL_PLAN=""

  while [ $current_time -lt $max_waiting_time ]
  do
    INSTALL_PLAN=$(kubectl get subscription "${SUBCRIPTION_NAME}" -o custom-columns=IPLAN:.status.installplan.name --no-headers -n "${DB2_PROJECT_NAME}" 2>/dev/null | grep -v "<none>" | cat)
    if [ ! -z "$INSTALL_PLAN" ]
    then
      break
    fi
    sleep 10
    current_time=$(( $current_time + 10 ))
  done

  echo "$INSTALL_PLAN"
}


function wait_for_resource_created_by_name {
  local resourceKind="statefulset"
  local timeToWait=45
  local max_waiting_time=$(( 60 * ${timeToWait}))
  local current_time=0
  local RESOURCE_FULLY_QUALIFIED_NAME=""

  while [ $current_time -lt $max_waiting_time ]
  do
    RESOURCE_FULLY_QUALIFIED_NAME=$(kubectl get "$resourceKind" "${C_DB2UCLUSTER_DB2U}"  -o name --no-headers -n "${DB2_PROJECT_NAME}" 2>/dev/null)
    if [ ! -z "$RESOURCE_FULLY_QUALIFIED_NAME" ]
    then
      break
    fi
    sleep 10
    current_time=$(( $current_time + 10 ))
  done

  echo "$RESOURCE_FULLY_QUALIFIED_NAME"
}


function get_worker_node_addresses_from_pod {
  local podName=$1
  local typeFilter=$3
  local HOST_NODE=""
  local HOST_ADDRESSES=""

  HOST_NODE=$(kubectl get pod "$podName" -o custom-columns=NODE:.spec.nodeName --no-headers 2>/dev/null)

  if [ ! -z "$typeFilter" ]
  then
    HOST_ADDRESSES=$(kubectl get node "$HOST_NODE" -o custom-columns="ADDRESS":".status.addresses[?(@.type==\"${typeFilter}\")].address" --no-headers 2>/dev/null)
  else
    HOST_ADDRESSES=$(kubectl get node "$HOST_NODE" -o custom-columns="ADDRESSES":'.status.addresses[*].address' --no-headers 2>/dev/null)
  fi

  echo "$HOST_ADDRESSES"
}

waiting_time=45
echo
echo "Waiting up to ${waiting_time} minutes for DB2 Operator install plan to be generated. ${DB2_PROJECT_NAME}"
date

installPlan=$(wait_for_install_plan)

if [ "$installPlan" ]
then
  echo $installPlan
else
  echo "Timed out waiting for DB2 install plan. Check status for CSV $DB2_STARTING_CSV"
  exit 1
fi

echo
echo "Approving DB2 Operator install plan."
kubectl patch installplan "$installPlan" --namespace "${DB2_PROJECT_NAME}" --type merge --patch '{"spec":{"approved":true}}'
echo

## Waiting up to 5 minutes for DB2 Operator installation to complete.
## The CSV name for the DB2 operator is exactly the version of the CSV hence
## using db2OperatorVersion as the operator name.
echo "Waiting for DB2 Operator to be installed. It may take up to 5 minutes or more ..."
date
operatorInstallStatus=$(wait_for_operator_to_install_successfully)
if [ "$operatorInstallStatus" ]
then
  echo "DB2 operator has been successfully installed."
  echo "$operatorInstallStatus"
else
  echo "Timed out waiting for DB2 operator to install.  Check status for CSV $DB2_STARTING_CSV"
  exit 1
fi

sleep 30


echo
echo "Deploying the Db2u-cluster ..."
kubectl --validate=false apply -f -<<EOF
${DB2U_CLUSTER_CONTENT}
EOF
echo

sleep 50
## Wait for c-db2ucluster-db2u statefulset to be created so that we can apply requried patch.
## This patch removes the issue that prevents the db2u pod from starting
echo
echo "Waiting for ${C_DB2UCLUSTER_DB2U} statefulset to be created ..."
date
statefulsetQualifiedName=$(wait_for_resource_created_by_name)
if [ "$statefulsetQualifiedName" ]
then
  echo "The Statefulset has been successfully created."
  echo "$statefulsetQualifiedName"
else
  echo "Timed out waiting for ${C_DB2UCLUSTER_DB2U} statefulset to be created by DB2 operator"
  exit 1
fi

echo
echo "Patching ${C_DB2UCLUSTER_DB2U} statefulset."

kubectl patch "$statefulsetQualifiedName" -n="${DB2_PROJECT_NAME}" -p='{"spec":{"template":{"spec":{"containers":[{"name":"db2u","tty":false}]}}}}}'

## Wait for  c-db2ucluster-restore-morph job to complte. If this job completes successfully
## we can tell that the deployment was completed successfully.

function wait_for_job_to_complete_by_name {

  local current_time=0
  local max_waiting_time=300

  until (kubectl get job "${C_DB2UCLUSTER_INSTDB}" -n "${DB2_PROJECT_NAME}" | grep Complete | cat) || [ "${current_time}" -eq "${max_waiting_time}" ] ;
  do
      current_time=$((current_time + 1))
      echo -e "......"
      sleep 10
      if [ "${current_time}" -eq "${max_waiting_time}" ] ; then
          echo -e "Timed out waiting for ${C_DB2UCLUSTER_DB2U}-0 pod to complete successfully."
          break
      fi
  done
}


echo
echo "Waiting for ${C_DB2UCLUSTER_INSTDB} job to complete successfully."
sleep 40
date
wait_for_job_to_complete_by_name


#
#if [ "$jobStatus" ]
#then
#  echo "Job Status: ${jobStatus}"
#  echo "${C_DB2UCLUSTER_INSTDB} job has been successfully completed."
#else
#  echo "Timed out waiting for ${C_DB2UCLUSTER_INSTDB} job to complete successfully."
#  exit 1
#fi


function wait_for_c_db2ucluster_db2u_pod {
  local current_time=0
  local max_waiting_time=300 total_wait_time

  until (kubectl get pods -n "${DB2_PROJECT_NAME}" | grep "${C_DB2UCLUSTER_DB2U}" | grep Running) || [ "${current_time}" -eq "${max_waiting_time}" ] ;
  do
      current_time=$((current_time + 1))
      echo -e "......"
      sleep 10
      if [ "${current_time}" -eq "${max_waiting_time}" ] ; then
          echo -e "Timed out waiting for ${C_DB2UCLUSTER_DB2U}-0 pod to complete successfully."
          break
      fi
  done
}


echo
echo "Waiting for "${C_DB2UCLUSTER_DB2U}"-0 pod to complete successfully."
date
sleep 20
wait_for_c_db2ucluster_db2u_pod



#if [ "$jobStatus" ]
#then
#  echo "Job Status: ${jobStatus}"
#  echo "${C_DB2UCLUSTER_DB2U}-0 job has been successfully completed."
#else
#  echo "Timed out waiting for ${C_DB2UCLUSTER_DB2U}-0 job to complete successfully."
#  exit 1
#fi


## Now that DB2 is running let's update the number of databases allowed 
## This is done by updating the NUMDB property in the ConfigMap c-db2ucluster-db2dbmconfig
echo
echo "Updating number of databases allowed by DB2 installation from 8 to 20."
kubectl get configmap c-db2ucluster-db2dbmconfig -n "$DB2_PROJECT_NAME" -o yaml | sed "s|NUMDB 8|NUMDB 20|" |  kubectl replace configmap -n "$DB2_PROJECT_NAME" --filename=-

echo
echo "Updating database manager running configuration."
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "$DB2_ADMIN_USERNAME" -c "db2 update dbm cfg using numdb 20"
sleep 10
echo
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "$DB2_ADMIN_USERNAME" -c "db2set DB2_WORKLOAD=FILENET_CM"
sleep 10
echo
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "$DB2_ADMIN_USERNAME" -c "set CUR_COMMIT=ON"
sleep 10

echo
echo "Restarting DB2 instance."
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "$DB2_ADMIN_USERNAME" -c "db2stop"
sleep 10
echo
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "$DB2_ADMIN_USERNAME" -c "db2start"
sleep 10

echo
echo
echo "****************************************************************************"
echo "********* USE THE FOLLOWING DB2 ENDPOINTS TO ACCESS THE DATABASE!!! *********"
echo "****************************************************************************"
echo
echo "=> Use this db2_host_address/IP to access the databases e.g. with IBM Data Studio."
routerCanonicalHostname=$(kubectl get route console -n openshift-console -o yaml | grep routerCanonicalHostname | cut -d ":" -f2)
echo -e "\tdb2_host_address:${routerCanonicalHostname}"

echo
echo "=> Use one of these NodePorts to access the databases e.g. with IBM Data Studio."
db2_ports=$(kubectl get svc -n "${DB2_PROJECT_NAME}" "${C_DB2UCLUSTER_DB2U}"-engn-svc -o json | grep  nodePort | cut -d ":" -f2)
echo -e "\tdb2_ports:${db2_ports}"

echo
workerNodeAddresses=$(get_worker_node_addresses_from_pod "${C_DB2UCLUSTER_DB2U}"-0)
echo "=> Other possible addresses(If hostname not available above):"
echo "${workerNodeAddresses}"

echo
echo "=> Use \"${DB2_ADMIN_USERNAME}\" and password \"${DB2_ADMIN_USER_PASSWORD}\" to access the databases e.g. with IBM Data Studio."

set +e

echo
echo "Removing BLUDB from system."
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "${DB2_ADMIN_USERNAME}" -c "db2 deactivate database BLUDB"
sleep 10
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "${DB2_ADMIN_USERNAME}" -c "db2 drop database BLUDB"
sleep 10
echo
echo "Existing databases are:"
kubectl -n "${DB2_PROJECT_NAME}" exec "${C_DB2UCLUSTER_DB2U}"-0 -- su - "${DB2_ADMIN_USERNAME}" -c "db2 list database directory | grep \"Database name\" | cat"
echo

echo "Db2u installation complete! Congratulations. Exiting ..."
date

echo
echo
echo "*********************************************************************************"
echo "******** Installation and configuration of DB2 completed successfully!!! ********"
echo "*********************************************************************************"

