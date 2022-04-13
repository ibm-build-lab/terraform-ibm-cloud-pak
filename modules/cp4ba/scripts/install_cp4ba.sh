#!/bin/bash
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
PARENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
K8S_CMD=kubectl


echo
echo
echo "*********************************************************************************"
echo "******************** Installating and configuring CP4BA ... *********************"
echo "*********************************************************************************"


  ###### Create the namespace
echo
echo "Creating \"${CP4BA_PROJECT_NAME}\" project ... "
${K8S_CMD} create namespace "${CP4BA_PROJECT_NAME}"
echo

###### Create the secrets
echo -e "Creating secret \"admin.registrykey\" in ${CP4BA_PROJECT_NAME}...\n"
CREATE_SECRET_RESULT=$(${K8S_CMD} create secret docker-registry admin.registrykey -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${ENTITLED_REGISTRY_EMAIL}")
sleep 5

if [[ ${CREATE_SECRET_RESULT} ]]; then
    echo -e "\"admin.registrykey\" secret has been created."
fi

echo
echo -e "Creating secret \"ibm-entitlement-key\" in ${CP4BA_PROJECT_NAME}...\n"
CREATE_SECRET_RESULT=$(${K8S_CMD} create secret docker-registry ibm-entitlement-key -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${ENTITLED_REGISTRY_EMAIL}")
sleep 5

if [[ ${CREATE_SECRET_RESULT} ]]; then
    echo -e "\"ibm-entitlement-key\" secret has been created"
fi
echo

echo -e "Creating remaining secrets...\n"
kubectl apply -n "${CP4BA_PROJECT_NAME}" -f -<<EOF
${SECRETS_CONTENT}
EOF


sleep 5
echo
echo -e "Creating the \"operator-shared-pv\" Persistent Volumes (PVs) ..."
kubectl --validate=false apply -f -<<EOF
${OPERATOR_SHARED_PV_CONTENT}
EOF

sleep 5
echo
echo -e "Creating the \"cp4a-shared-log-pv\" Persistent Volumes (PVs) ..."
kubectl --validate=false apply -f -<<EOF
${SHARED_LOG_PV_CONTENT}
EOF

sleep 10

echo
echo -e "Creating \"operator-shared-pvc\" Persistent Volume Claim (PVC) ..."
kubectl --validate=false apply -f -<<EOF
${OPERATOR_SHARED_PVC_CONTENT}
EOF


echo
echo -e "Creating \"cp4a-shared-log-pvc\" Persistent Volume Claim (PVC) ..."
kubectl --validate=false apply -f -<<EOF
${SHARED_LOG_PVC_CONTENT}
EOF
echo
sleep 20

function check_pvc() {

  echo "************** PVC **************"

  ATTEMPTS=0
  TIMEOUT=100

  for name in operator-shared-pvc cp4a-shared-log-pvc;
  do
      if (kubectl get pvc -n "${CP4BA_PROJECT_NAME}" | grep $name | grep Bound)
      then
        echo -e "The \"$name\"  Persistent Volume Claim has been created."
        echo "$results"
        echo
        if [ "$name" == cp4a-shared-log-pvc ]
        then
          break
        fi
      else
        echo -e "Waiting for the Persistent Volume Claims to be ready..."
        until (kubectl get pvc -n "${CP4BA_PROJECT_NAME}" | grep $name | grep "Bound") || [ $ATTEMPTS -eq $TIMEOUT ] ; do
            ATTEMPTS=$((ATTEMPTS + 1))
            echo -e "......"
            sleep 10
            if [ $ATTEMPTS -eq $TIMEOUT ] ; then
                echo -e "Failed! Please check the PVCs. You probably need to recreate the PVCs."
                break
            fi
        done
        continue
      fi
  done
}

function check_pv() {
  echo
  echo
  echo "************** PV **************"

  ATTEMPTS=0
  TIMEOUT=100

  for name in operator-shared-pvc cp4a-shared-log-pvc;
  do
      results=$(kubectl get pv -n "${CP4BA_PROJECT_NAME}" | grep $name | grep Bound)
      if [ "$results" ]
      then
        echo -e "The \"$name\"  Persistent Volume has been created."
        echo "$results"
        echo
        if [ "$name" == "cp4a-shared-log-pvc" ]
        then
          echo
          check_pvc
        fi
      else
        echo -e "Waiting for the Persistent Volumes to be ready..."
        until (kubectl get pv -n "${CP4BA_PROJECT_NAME}" | grep $name | grep "Bound") || [ $ATTEMPTS -eq $TIMEOUT ] ; do
            ATTEMPTS=$((ATTEMPTS + 1))
            echo -e "......"
            sleep 10
            if [ $ATTEMPTS -eq $TIMEOUT ] ; then
                echo -e "Failed! Please check the PVs. You probably need to recreate the PVs"
                echo
                echo
                check_pvc
            fi
        done
        continue
      fi
  done

}

check_pv

# CREATING OPERATOR GROUP
echo -e "Creating Operator Group ..."
${K8S_CMD} apply -f -<<EOF
${OPERATOR_GROUP_CONTENT}
EOF
echo
sleep 5

###### Add the CatalogSource resources to Operator Hub
# Creating roles
echo -e "Creating roles ..."
cat "${ROLES_FILE}"
${K8S_CMD} apply -f "${ROLES_FILE}" -n "${CP4BA_PROJECT_NAME}"
echo

sleep 2

# Creating roles
echo -e "Creating role binding ..."
cat "${ROLE_BINDING_FILE}"
${K8S_CMD} apply -f "${ROLE_BINDING_FILE}" -n "${CP4BA_PROJECT_NAME}"
echo

sleep 2

# Deploy common-service
echo -e "Creating common-service namespace ..."
${K8S_CMD} create namespace common-service
echo


# Add the CatalogSource resources to Operator Hub
echo -e "Creating the Catalog Source ..."
cat "${CATALOG_SOURCE_FILE}"
${K8S_CMD} apply -f "${CATALOG_SOURCE_FILE}"
sleep 10
echo

function check_catalogsources() {
  echo
  echo
  echo "************** Checking the IBM Catalog-Sources **************"

  ATTEMPTS=0
  TIMEOUT=60

  for name in ibm-cp4a-operator-catalog ibm-operator-catalog opencloud-operators ;
  do
      results=$(kubectl get catalogsources -n openshift-marketplace | grep $name )
      if [ "$results" ]
      then
        echo -e "The \"$name\" has been created."
        echo "$results"
        echo
        if [ "$name" == "opencloud-operators" ]
        then
          echo
          break
        fi
      else
        echo -e "Waiting for the Catalog-Sources to be created ..."
        until (kubectl get catalogsources -n openshift-marketplace | grep $name ) || [ $ATTEMPTS -eq $TIMEOUT ] ; do
            ATTEMPTS=$((ATTEMPTS + 1))
            echo -e "......"
            sleep 10
            if [ $ATTEMPTS -eq $TIMEOUT ] ; then
                echo -e "Failed! Please check the Catalog-Sources. You probably need to recreate the Catalog-Sources'."
                echo
                echo
            fi
        done
        continue
      fi
  done
}

check_catalogsources
echo

echo -e "Deploying common-service ..."
cat "${COMMON_SERVICE_FILE}"
${K8S_CMD} apply -f "${COMMON_SERVICE_FILE}"
sleep 50
echo

# Create subscription to Business Automation Operator
echo -e "Creating the Subscription ..."
${K8S_CMD} -n "${CP4BA_PROJECT_NAME}" apply -f -<<EOF
${CP4BA_SUBSCRIPTION_CONTENT}
EOF
sleep 30
echo

function check_subscription() {
  echo
  echo
  echo "************** Checking the IBM CP4BA Operator Subscriptions **************"

  ATTEMPTS=0
  TIMEOUT=100

  for name in ibm-automation-core ibm-common-service-operator ibm-cp4a-operator ;
  do
      results=$(kubectl get subs -n "${CP4BA_PROJECT_NAME}" | grep $name )
      if [ "$results" ]
      then
        echo -e "The \"$name\" has been created."
        echo "$results"
        echo
        if [ "$name" == "ibm-cp4a-operator" ]
        then
          echo
          break
        fi
      else
        echo -e "Waiting for the Operator Subscriptions to be ready ..."
        until (kubectl get subs -n "${CP4BA_PROJECT_NAME}" | grep $name ) || [ $ATTEMPTS -eq $TIMEOUT ] ; do
            ATTEMPTS=$((ATTEMPTS + 1))
            echo -e "......"
            sleep 10
            if [ $ATTEMPTS -eq $TIMEOUT ] ; then
                echo -e "Failed! Please check the Operator Subscriptions. You probably need to recreate the 'cp4ba_subscription.yaml.tmpl'"
                echo
                echo
            fi
        done
        continue
      fi
  done
}

check_subscription
echo

# Create Deployment Credentials
echo -e "Creating the Deployment Credentials ..."
${K8S_CMD} --validate=false -n "${CP4BA_PROJECT_NAME}" apply  -f -<<EOF
${CP4BA_DEPLOYMENT_CREDENTIALS_CONTENT}
EOF
echo


# Create Deployment
echo -e "Creating the Deployment ..."
${K8S_CMD} --validate=false -n "${CP4BA_PROJECT_NAME}" apply -f -<<EOF
${CP4BA_DEPLOYMENT_CONTENT}
EOF
sleep 20

echo

function check_icp4adeploy() {
  echo
  echo
  echo "************** Checking the Deployment Pods 'icp4adeploy' **************"

  ATTEMPTS=0
  TIMEOUT=800

  for name in icp4adeploy-rr-setup-pod ;
  do
      results=$(kubectl get pods -n "${CP4BA_PROJECT_NAME}" | grep $name | grep Completed)
      if [ "$results" ]
      then
        echo -e "Deployment Setup Pod \"$name\" has been completed."
        echo "$results"
        echo
        kubectl get pods -n "${CP4BA_PROJECT_NAME}" | grep deploy
        echo
        if [ "$name" == "icp4adeploy-rr-setup-pod" ]
        then
          echo
          break
        fi
      else
        echo -e "Waiting for the Deployment Setup Pods to be ready ..."
        until (kubectl get pods -n "${CP4BA_PROJECT_NAME}" | grep $name | grep Completed) || [ $ATTEMPTS -eq $TIMEOUT ] ; do
            ATTEMPTS=$((ATTEMPTS + 1))
            echo -e "......"
            sleep 10
            if [ $ATTEMPTS -eq $TIMEOUT ] ; then
                echo -e "Failed! Please check the Deployment Setup Pod. You probably need to recreate the 'cp4ba_deployment.yaml.tmpl'"
                echo
                echo
            fi
        done
        continue
      fi
  done
}

check_icp4adeploy

echo

${K8S_CMD} get pods -n openshift-marketplace | grep ibm-cp4a-operator
result=$?
counter=0
while [[ "${result}" -ne 0 ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "The CP4BA Operator was not created within ten minutes; please attempt to install the product again."
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for CP4BA operator pod to provision"
    sleep 30;
    ${K8S_CMD} get pods -n openshift-marketplace | grep ibm-cp4a-operator
    result=$?
done

echo
echo
echo "*********************************************************************************"
echo "******* Installation and configuration of CP4BA completed successfully!!! *******"
echo "*********************************************************************************"

echo
echo
echo "****************************************************************************"
echo "****************** USE THESE ENDPOINTS TO ACCESS CP4BA *********************"
echo "****************************************************************************"








