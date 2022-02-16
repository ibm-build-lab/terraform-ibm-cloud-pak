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
OC_CMD=oc

. ../../modules/Db2/scripts/common-ocp-utils.sh


echo "Creating Storage Class ..."
${OC_CMD} apply -f ${DB2_STORAGE_CLASS_FILE}
sleep 10

echo "Docker username: ${DOCKER_USERNAME}"
${OC_CMD} create secret docker-registry ibm-registry --docker-server=${DOCKER_SERVER} --docker-username=${DOCKER_USERNAME} --docker-password=${ENTITLED_REGISTRY_KEY} --docker-email=${ENTITLEMENT_REGISTRY_USER_EMAIL} --namespace=ibm-db2

sleep 10

kubectl patch storageclass ibmc-block-gold -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass cp4a-file-retain-gold-gid -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

oc get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i.bak "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'

echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(oc get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; oc get secret ibm-registry -n ${DB2_PROJECT_NAME} --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged


echo
echo "Installing the IBM Operator Catalog..."
${OC_CMD} apply -f ${DB2_OPERATOR_CATALOG_FILE}

echo
echo "Creating project ${DB2_PROJECT_NAME}..."
${OC_CMD} new-project ${DB2_PROJECT_NAME}
${OC_CMD} project ${DB2_PROJECT_NAME}

echo
echo "You can get the Entitlement Registry key from here: https://myibm.ibm.com/products-services/containerlibrary"
echo

echo "Docker username: ${DOCKER_USERNAME}"
${OC_CMD} create secret docker-registry ibm-db2-registry --docker-server=${DOCKER_SERVER} --docker-username=${DOCKER_USERNAME} --docker-password=${ENTITLED_REGISTRY_KEY} --docker-email=${ENTITLEMENT_REGISTRY_USER_EMAIL} --namespace=ibm-db2


echo "Preparing the cluster for Db2..."
${OC_CMD} get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i.bak "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'

echo
echo "Modifying the OpenShift Global Pull Secret (you need jq tool for that):"
echo $(${OC_CMD} get secret pull-secret -n openshift-config --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode; oc get secret ibm-db2-registry -n ${DB2_PROJECT_NAME} --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode) | jq -s '.[0] * .[1]' > dockerconfig_merged
${OC_CMD} set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=dockerconfig_merged

echo

if ${OC_CMD} get catalogsource -n openshift-marketplace | grep ibm-operator-catalog ; then
        echo "Found ibm operator catalog source"
    else
        ${OC_CMD} apply -f "${DB2_OPERATOR_CATALOG_FILE}"
        if [ $? -eq 0 ]; then
          echo "IBM Operator Catalog source created!"
        else
          echo "Generic Operator catalog source creation failed"
          exit 1
        fi
    fi

    maxRetry=20
    for ((retry=0;retry<=${maxRetry};retry++)); do
      echo "Waiting for Db2u Operator Catalog pod initialization"

      isReady=$(${OC_CMD} get pod -n openshift-marketplace --no-headers | grep ibm-operator-catalog | grep "Running")
      if [[ -z $isReady ]]; then
        if [[ $retry -eq ${maxRetry} ]]; then
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

## 
## Creating DB2 Operator Group 
##
echo
echo "Creating Operator Group object for DB2 Operator"
cp  ../../modules/Db2/templates/db2-operatorgroup.template.yaml  ../../modules/Db2/files/db2-operatorgroup.yaml
sed -i.bak "s|paramDB2Namespace|$DB2_PROJECT_NAME|g" ../../modules/Db2/files/db2-operatorgroup.yaml
oc apply -f ../../modules/Db2/files/db2-operatorgroup.yaml


###### Create subscription to Db2 Operator
echo -e "\x1B[1mCreating the Subscription...\n${DB2_SUBSCRIPTION_FILE}\n\x1B[0m"
kubectl apply -f ${DB2_SUBSCRIPTION_FILE}

echo
echo "Creating Subscription object for DB2 Operator"
cp ../../modules/Db2/templates/db2-subscription.template.yaml ../../modules/Db2/files/db2-subscription.yaml

sed -i.bak "s|paramDB2Namespace|$DB2_PROJECT_NAME|g" ../../modules/Db2/files/db2-subscription.yaml
sed -i.bak "s|paramDB2OperatorVersion|$DB2_OPERATOR_VERSION|g" ../../modules/Db2/files/db2-subscription.yaml
sed -i.bak "s|paramDB2OperatorChannel|$DB2_OPERATOR_CHANNEL|g" ../../modules/Db2/files/db2-subscription.yaml
oc apply -f ../../modules/Db2/files/db2-subscription.yaml



###### Create subscription to Db2 Operator
#echo -e "\x1B[1mCreating the Subscription...\n${DB2_SUBSCRIPTION_FILE}\n\x1B[0m"
#kubectl apply -f ${DB2_OPERATOR_GROUP_FILE}

echo
echo "Waiting up to 5 minutes for DB2 Operator install plan to be generated. $DB2_PROJECT_NAME"
date
installPlan=$(wait_for_install_plan "db2u-operator" 5 $DB2_PROJECT_NAME)
if [ -z "$installPlan" ]
then
  echo "Timed out waiting for DB2 install plan. Check status for CSV $DB2_STARTING_CSV"
  exit 1
fi

##
## Approve DB2 Operator install plan.
##
echo
echo "Approving DB2 Operator install plan."
oc patch installplan $installPlan --namespace ${DB2_PROJECT_NAME} --type merge --patch '{"spec":{"approved":true}}'
##
## Waiting up to 5 minutes for DB2 Operator installation to complete.
## The CSV name for the DB2 operator is exactly the version of the CSV hence
## using db2OperatorVersion as the operator name.
##
echo "Waiting up to 5 minutes for DB2 Operator to install."
date
operatorInstallStatus=$(wait_for_operator_to_install_successfully $DB2_STARTING_CSV 5 $DB2_PROJECT_NAME)
if [ -z "$operatorInstallStatus" ]
then
  echo "Timed out waiting for DB2 operator to install.  Check status for CSV $DB2_STARTING_CSV"
  exit 1
fi

echo "Deploying the Db2u cluster ..."

cp ../../modules/Db2/templates/db2_tmpl.yaml ../../modules/Db2/files/db2.yaml

sed -i.bak "s|db2OnOcpProjectName|$DB2_PROJECT_NAME|g" ../../modules/Db2/files/db2.yaml
sed -i.bak "s|db2AdminUserPassword|$DB2_ADMIN_USER_PASSWORD|g" ../../modules/Db2/files/db2.yaml
sed -i.bak "s|db2InstanceVersion|$DB2_INSTANCE_VERSION|g" ../../modules/Db2/files/db2.yaml
sed -i.bak "s|db2Cpu|$DB2_CPU|g" ../../modules/Db2/files/db2.yaml
sed -i.bak "s|db2Memory|$DB2_MEMORY|g" ../../modules/Db2/files/db2.yaml
sed -i.bak "s|db2StorageSize|$DB2_STORAGE_SIZE|g" ../../modules/Db2/files/db2.yaml
sed -i.bak "s|db2OnOcpStorageClassName|$DB2_STORAGE_CLASS|g" ../../modules/Db2/files/db2.yaml

db2License="accept: true"
if [ "$DB2_STANDARD_LICENSE_KEY" == "" ]; then
   db2License="accept: true"
else
   db2License="value: $DB2_STANDARD_LICENSE_KEY"
fi
sed -i.bak "s|db2License|$db2License|g" ../../modules/Db2/files/db2.yaml

oc apply -f ../../modules/Db2/files/db2.yaml

##
## Create the DB2 Cluster instance using our predefined template
##
#echo
#echo "Deploying the Db2u cluster."
#cp db2.template.yaml db2.yaml
#sed -i.bak "s|db2OnOcpProjectName|$db2OnOcpProjectName|g" db2.yaml
#sed -i.bak "s|db2AdminUserPassword|$db2AdminUserPassword|g" db2.yaml
#sed -i.bak "s|db2InstanceVersion|$db2InstanceVersion|g" db2.yaml
#sed -i.bak "s|db2Cpu|$db2Cpu|g" db2.yaml
#sed -i.bak "s|db2Memory|$db2Memory|g" db2.yaml
#sed -i.bak "s|db2StorageSize|$db2StorageSize|g" db2.yaml
#sed -i.bak "s|db2OnOcpStorageClassName|$db2OnOcpStorageClassName|g" db2.yaml
#db2License="accept: true"
#if [ "$db2StandardLicenseKey" == "" ]; then
#   db2License="accept: true"
#else
#   db2License="value: $db2StandardLicenseKey"
#fi
#sed -i.bak "s|db2License|$db2License|g" db2_tmpl.yaml

#oc apply -f ../../modules/Db2/files/db2_tmpl.yaml

##
## Wait for c-db2ucluster-db2u statefulset to be created so that we can apply requried patch.
## This patch removes the tty issue that prevents the db2u pod from starting
##
echo
echo "Waiting up to 15 minutes for c-db2ucluster-db2u statefulset to be created."
date
statefulsetQualifiedName=$(wait_for_resource_created_by_name statefulset c-db2ucluster-db2u 15 $DB2_PROJECT_NAME)
if [ -z "$statefulsetQualifiedName" ]
then
  echo "Timed out waiting for c-db2ucluster-db2u statefulset to be created by DB2 operator"
  exit 1
fi

echo
echo "Patching c-db2ucluster-db2u statefulset."
oc patch $statefulsetQualifiedName -n=$db2OnOcpProjectName -p='{"spec":{"template":{"spec":{"containers":[{"name":"db2u","tty":false}]}}}}}'

##
## Wait for  c-db2ucluster-restore-morph job to complte. If this job completes successfully
## we can tell that the deployment was completed successfully.
##
echo
echo "Waiting up to 15 minutes for c-db2ucluster-restore-morph job to complete successfully."
date
jobStatus=$(wait_for_job_to_complete_by_name c-db2ucluster-restore-morph 15 $DB2_PROJECT_NAME)
if [ -z "$jobStatus" ]
then
  echo "Timed out waiting for c-db2ucluster-restore-morph job to complete successfully."
  exit 1
fi

##
## Now that DB2 is running let's update the number of databases allowed 
## This is done by updating the NUMDB property in the ConfigMap c-db2ucluster-db2dbmconfig 
##
echo
echo "Updating number of databases allowed by DB2 installation from 8 to 20."
oc get configmap c-db2ucluster-db2dbmconfig -n $DB2_PROJECT_NAME -o yaml | sed "s|NUMDB 8|NUMDB 20|" |  oc replace configmap -n $DB2_PROJECT_NAME --filename=-

echo
echo "Updating database manager running configuration."
oc exec c-db2ucluster-db2u-0 -it -- su - $DB2_ADMIN_USERNAME -c "db2 update dbm cfg using numdb 20"
sleep 10 #let DB2 settle down
oc exec c-db2ucluster-db2u-0 -it -- su - $DB2_ADMIN_USERNAME -c "db2set DB2_WORKLOAD=FILENET_CM"
sleep 10 #let DB2 settle down
oc exec c-db2ucluster-db2u-0 -it -- su - $DB2_ADMIN_USERNAME -c "set CUR_COMMIT=ON"
sleep 10 #let DB2 settle down

echo
echo "Restarting DB2 instance."
oc exec c-db2ucluster-db2u-0 -it -- su - $DB2_ADMIN_USERNAME -c "db2stop"
sleep 10 #let DB2 settle down
oc exec c-db2ucluster-db2u-0 -it -- su - $DB2_ADMIN_USERNAME -c "db2start"
sleep 10 #let DB2 settle down



echo
echo "Existing databases are:"
${OC_CMD} exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 list database directory | grep \"Database name\""

echo
echo "Use this hostname/IP to access the databases e.g. with IBM Data Studio."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2HostName\" with this information (in Skytap, use the IP 10.0.0.10 instead).\x1B[0m"
${OC_CMD} get route console -n openshift-console -o yaml | grep routerCanonicalHostname

echo
echo "Use one of these NodePorts to access the databases e.g. with IBM Data Studio (usually the first one is for legacy-server (Db2 port 50000), the second for ssl-server (Db2 port 50001))."
echo "\x1B[1mPls. also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2PortNumber\" with this information (legacy-server).\x1B[0m"
${OC_CMD} get svc -n ${DB2_PROJECT_NAME} c-db2ucluster-db2u-engn-svc -o json | grep nodePort

echo
echo "Use \"${DB2_ADMIN_USER_NAME}\" and password \"${DB2_ADMIN_USER_PASSWORD}\" to access the databases e.g. with IBM Data Studio."

set +e
echo
echo "*********************************************************************************"
echo "********* Installation and configuration of DB2 completed successfully! *********"
echo "*********************************************************************************"
echo
echo "Removing BLUDB from system."
oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME} -c "db2 deactivate database BLUDB"
sleep 10 #let DB2 settle down
oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME}  -c "db2 drop database BLUDB"
sleep 10 #let DB2 settle down
echo
echo "Existing databases are:"
oc exec c-db2ucluster-db2u-0 -it -- su - ${DB2_ADMIN_USER_NAME}  -c "db2 list database directory | grep \"Database name\" | cat"
echo
echo "Use this hostname/IP to access the databases e.g. with IBM Data Studio."
echo -e "\x1B[1mPlease also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2HostName\" with this information (in Skytap, use the IP 10.0.0.10 instead)\x1B[0m"
routerCanonicalHostname=$(oc get route console -n openshift-console -o yaml | grep routerCanonicalHostname | cut -d ":" -f2)
workerNodeAddresses=$(get_worker_node_addresses_from_pod c-db2ucluster-db2u-0 ${PROJECT_NAME} )
echo -e "\tHostname:${routerCanonicalHostname}"
echo -e "\tOther possible addresses(If hostname not available above): $workerNodeAddresses"
echo
echo "Use one of these NodePorts to access the databases e.g. with IBM Data Studio (usually the first one is for legacy-server (Db2 port 50000), the second for ssl-server (Db2 port 50001))."
echo -e "\x1B[1mPlease also update in ${DB2_INPUT_PROPS_FILENAME} property \"db2PortNumber\" with this information (legacy-server).\x1B[0m"
oc get svc -n "ibm-db2" c-db2ucluster-db2u-engn-svc -o json | grep nodePort
echo
echo "Use \"${DB2_ADMIN_USER_NAME} \" and password \"${DB2_ADMIN_USER_PASSWORD} \" to access the databases e.g. with IBM Data Studio."
echo
echo "Db2u installation complete! Congratulations. Exiting..."