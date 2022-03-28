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

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo
echo "Creating project ${DB2_PROJECT_NAME}..."
kubectl new-project "${DB2_PROJECT_NAME}"
kubectl project "${DB2_PROJECT_NAME}"
echo

#. ../../modules/Db2/scripts/common-ocp-utils.sh
"${CUR_DIR}"/common-ocp-utils.sh


echo "Creating Storage Class ..."
kubectl apply -f "${DB2_STORAGE_CLASS_FILE}"
sleep 10

echo "Docker username: ${DOCKER_USERNAME}"
kubectl create secret docker-registry ibm-registry --docker-server="${DOCKER_SERVER}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-email="${ENTITLEMENT_REGISTRY_USER_EMAIL}" --namespace="${DB2_PROJECT_NAME}"

sleep 10

kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass cp4a-file-retain-gold-gid -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i.bak "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'

echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(kubectl get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; kubectl get secret ibm-registry -n "${DB2_PROJECT_NAME}" --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
kubectl set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo
echo "Installing the IBM Operator Catalog..."
kubectl apply -f -<<EOF
${DB2_OPERATOR_CATALOG_FILE}
EOF
#kubectl apply -f "${DB2_OPERATOR_CATALOG_FILE}"

echo
echo "You can get the Entitlement Registry key from here: https://myibm.ibm.com/products-services/containerlibrary"
echo

echo "Docker username: ${DOCKER_USERNAME}"
kubectl create secret docker-registry ibm-db2-registry --docker-server="${DOCKER_SERVER}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-email="${ENTITLEMENT_REGISTRY_USER_EMAIL}" --namespace="${DB2_PROJECT_NAME}"
echo

echo "Preparing the cluster for Db2..."
kubectl get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i.bak "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'

echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(kubectl get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; oc get secret ibm-db2-registry -n ${DB2_PROJECT_NAME} --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
kubectl set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo

if kubectl get catalogsource -n openshift-marketplace | grep ibm-operator-catalog ; then
        echo "Found ibm operator catalog source"
    else
        kubectl apply -f -<<EOF
${DB2_OPERATOR_CATALOG_FILE}
EOF
#        kubectl apply -f "${DB2_OPERATOR_CATALOG_FILE}"
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
${DB2_OPERATOR_GROUP_FILE}
EOF
#cat "${DB2_OPERATOR_GROUP_FILE}"
#kubectl apply -f "${DB2_OPERATOR_GROUP_FILE}"
echo

###### Create subscription to Db2 Operator
echo -e "\x1B[1m Creating Subscription object for DB2 Operator ... \x1B[0m"
kubectl apply -f -<<EOF
${DB2_SUBSCRIPTION_FILE}
EOF
#cat "${DB2_SUBSCRIPTION_FILE}"
#kubectl apply -f "${DB2_SUBSCRIPTION_FILE}"
echo

waiting_time=20
echo
echo "Waiting up to ${waiting_time} minutes for DB2 Operator install plan to be generated. $DB2_PROJECT_NAME"
date

installPlan=$(wait_for_install_plan "db2u-operator" ${waiting_time} "$DB2_PROJECT_NAME")
if [ -z "$installPlan" ]
then
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
timer_2=10
echo "Waiting up to 5 minutes for DB2 Operator to install."
date
operatorInstallStatus=$(wait_for_operator_to_install_successfully "${DB2_OPERATOR_VERSION}" ${timer_2} "$DB2_PROJECT_NAME")
if [ -z "$operatorInstallStatus" ]
then
  echo "Timed out waiting for DB2 operator to install.  Check status for CSV $DB2_STARTING_CSV"
  exit 1
fi

echo
echo "Deploying the Db2u-cluster ..."
kubectl apply -f -<<EOF
${DB2U_CLUSTER_FILE}
EOF
#cat "${DB2U_CLUSTER_FILE}"
#kubectl apply -f "${DB2U_CLUSTER_FILE}"
echo

## Wait for c-db2ucluster-db2u statefulset to be created so that we can apply requried patch.
## This patch removes the issue that prevents the db2u pod from starting
echo
echo "Waiting up to 15 minutes for c-db2ucluster-db2u statefulset to be created ..."
date
statefulsetQualifiedName=$(wait_for_resource_created_by_name statefulset c-db2ucluster-db2u 15 "$DB2_PROJECT_NAME")
if [ -z "$statefulsetQualifiedName" ]
then
  echo "Timed out waiting for c-db2ucluster-db2u statefulset to be created by DB2 operator"
  exit 1
fi

echo
echo "Patching c-db2ucluster-db2u statefulset."

kubectl patch "$statefulsetQualifiedName" -n="${DB2_PROJECT_NAME}" -p='{"spec":{"template":{"spec":{"containers":[{"name":"db2u","tty":false}]}}}}}'

## Wait for  c-db2ucluster-restore-morph job to complte. If this job completes successfully
## we can tell that the deployment was completed successfully.
echo
echo "Waiting up to 15 minutes for c-db2ucluster-restore-morph job to complete successfully."
date
jobStatus=$(wait_for_job_to_complete_by_name c-db2ucluster-restore-morph 15 "$DB2_PROJECT_NAME")
if [ -z "$jobStatus" ]
then
  echo "Timed out waiting for c-db2ucluster-restore-morph job to complete successfully."
  exit 1
fi

## Now that DB2 is running let's update the number of databases allowed 
## This is done by updating the NUMDB property in the ConfigMap c-db2ucluster-db2dbmconfig
echo
echo "Updating number of databases allowed by DB2 installation from 8 to 20."
kubectl get configmap c-db2ucluster-db2dbmconfig -n "$DB2_PROJECT_NAME" -o yaml | sed "s|NUMDB 8|NUMDB 20|" |  oc replace configmap -n "$DB2_PROJECT_NAME" --filename=-

echo
echo "Updating database manager running configuration."
kubectl exec c-db2ucluster-db2u-0 -it -- su - "$DB2_ADMIN_USERNAME" -c "db2 update dbm cfg using numdb 20"
sleep 10
kubectl exec c-db2ucluster-db2u-0 -it -- su - "$DB2_ADMIN_USERNAME" -c "db2set DB2_WORKLOAD=FILENET_CM"
sleep 10
kubectl exec c-db2ucluster-db2u-0 -it -- su - "$DB2_ADMIN_USERNAME" -c "set CUR_COMMIT=ON"
sleep 10

echo
echo "Restarting DB2 instance."
kubectl exec c-db2ucluster-db2u-0 -it -- su - "$DB2_ADMIN_USERNAME" -c "db2stop"
sleep 10
kubectl exec c-db2ucluster-db2u-0 -it -- su - "$DB2_ADMIN_USERNAME" -c "db2start"
sleep 10



echo
echo "Existing databases are:"
kubectlexec c-db2ucluster-db2u-0 -it -- su - "${DB2_ADMIN_USER_NAME}" -c "db2 list database directory | grep \"Database name\""

echo
echo "Use this hostname/IP to access the databases e.g. with IBM Data Studio."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2HostName\" with this information (in Skytap, use the IP 10.0.0.10 instead).\x1B[0m"
kubectl get route console -n openshift-console -o yaml | grep routerCanonicalHostname

echo
echo "Use one of these NodePorts to access the databases e.g. with IBM Data Studio (usually the first one is for legacy-server (Db2 port 50000), the second for ssl-server (Db2 port 50001))."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2PortNumber\" with this information (legacy-server).\x1B[0m"
kubectl get svc -n "${DB2_PROJECT_NAME}" c-db2ucluster-db2u-engn-svc -o json | grep nodePort

echo
echo "Use \"${DB2_ADMIN_USER_NAME}\" and password \"${DB2_ADMIN_USER_PASSWORD}\" to access the databases e.g. with IBM Data Studio."

set +e
echo
echo "*********************************************************************************"
echo "********* Installation and configuration of DB2 completed successfully! *********"
echo "*********************************************************************************"
echo
echo "Removing BLUDB from system."
kubectl exec c-db2ucluster-db2u-0 -it -- su - "${DB2_ADMIN_USER_NAME}" -c "db2 deactivate database BLUDB"
sleep 10
kubectl exec c-db2ucluster-db2u-0 -it -- su - "${DB2_ADMIN_USER_NAME}"  -c "db2 drop database BLUDB"
sleep 10
echo
echo "Existing databases are:"
kubectl exec c-db2ucluster-db2u-0 -it -- su - "${DB2_ADMIN_USER_NAME}"  -c "db2 list database directory | grep \"Database name\" | cat"
echo
echo "Use this hostname/IP to access the databases e.g. with IBM Data Studio."
echo -e "\x1B[1mPlease also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2HostName\" with this information (in Skytap, use the IP 10.0.0.10 instead)\x1B[0m"
routerCanonicalHostname=$(kubectl get route console -n openshift-console -o yaml | grep routerCanonicalHostname | cut -d ":" -f2)
workerNodeAddresses=$(get_worker_node_addresses_from_pod c-db2ucluster-db2u-0 "${PROJECT_NAME}" )
echo -e "\tHostname:${routerCanonicalHostname}"
echo -e "\tOther possible addresses(If hostname not available above): $workerNodeAddresses"
echo
echo "Use one of these NodePorts to access the databases e.g. with IBM Data Studio (usually the first one is for legacy-server (Db2 port 50000), the second for ssl-server (Db2 port 50001))."
echo -e "\x1B[1mPlease also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2PortNumber\" with this information (legacy-server).\x1B[0m"
kubectl get svc -n "${DB2_PROJECT_NAME}" c-db2ucluster-db2u-engn-svc -o json | grep nodePort
echo
echo "Use \"${DB2_ADMIN_USER_NAME} \" and password \"${DB2_ADMIN_USER_PASSWORD} \" to access the databases e.g. with IBM Data Studio."
echo
echo "Db2u installation complete! Congratulations. Exiting..."