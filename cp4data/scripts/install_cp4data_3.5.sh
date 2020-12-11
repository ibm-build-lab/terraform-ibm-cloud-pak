#!/bin/sh

# Required input parameters
# - KUBECONFIG : Not used directly but required by oc

# Optional input parameters with default values
# - DATA_NAMESPACE
# - STORAGE_CLASS_NAME

# Software requirements:
# - oc
# - curl

# TODO: Confirm these parameters are required:
# - ENTITLED_REGISTRY_KEY         : Required to create the docker-registry secret but maybe this acrtion is not needed
# - ENTITLED_REGISTRY_USER_EMAIL  : Required to create the docker-registry secret but maybe this acrtion is not needed
# - CLUSTER_ENDPOINT              : Required to login with oc, but maybe this is not needed
# - OPENSHIFT_VERSION             : Current actions are just for ROKS 4.5, the actions for previous versions need to be included

DATA_NAMESPACE=${DATA_NAMESPACE:-cloudpak4data}
STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME:-ibmc-file-gold-gid}
ADMIN=${ADMIN:-cp4data-sandbox-adm}
ENTITLED_REGISTRY_USER=${ENTITLED_REGISTRY_USER:-cp}

# By default the persistent volume, the data, and your physical file storage device are deleted when CP4D is deprovisioned or the cluster destroyed.
# TODO: Other values for STORAGE_CLASS_NAME could be:
# - To retain/persist the storage after destroy the cluster, use 'ibmc-file-retain-gold-gid'
# - If using Portworx, use 'portworx-shared-gp3'
# - If using OpenShift Container Storage, use 'ocs-storagecluster-cephfs'

# Constants:
VERSION=3.5.1
EDITION_NAME="Standard Edition"
EDITION=SE
# EDITION_NAME="Enterprise Edition"
# EDITION=EE
OS_NAME=$(uname | tr '[:upper:]' '[:lower:]')
ARCHITECTURE=$(uname -m)
INSTALLER_URL="https://github.com/IBM/cpd-cli/releases/download/v3.5.0/cpd-cli-$OS_NAME-$EDITION-$VERSION.tgz"
INSTALL_DIR=./cloudpak4data

FMT_INF="\x1B[93;1m[INSTALLER : INFO ]\x1B[0m\x1B[93m"
FMT_ERR="\x1B[91;1m[INSTALLER : ERROR]\x1B[0m\x1B[91m"
FMT_END="\x1B[0m"

echo "${FMT_INF} Downloading the cp4data ${EDITION_NAME} installer v${VERSION} ...${FMT_END}"
echo "${FMT_INF} ... from ${INSTALLER_URL}${FMT_END}"
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR
curl -sSL "$INSTALLER_URL" \
  | tar -xvzf - -C $INSTALL_DIR

cd $INSTALL_DIR

v=$(./cpd-cli version | grep 'CPD Release Version' | cut -f2 -d: | tr -d ' ')
[[ "$v" == "$VERSION" ]] || {
  echo "${FMT_ERR} Failed to install CPD version $VERSION${FMT_END}"
  exit 1
}
echo "${FMT_INF} CPD v$v installed${FMT_END}"

# echo "${FMT_INF} Creating namespace ${DATA_NAMESPACE}${FMT_END}"
# oc create namespace ${DATA_NAMESPACE} --dry-run=client -o yaml | oc apply -f -

echo "${FMT_INF} Setting valid route to containers registry for IBM Cloud Pak for Data images${FMT_END}"
oc patch configs.imageregistry.operator.openshift.io/cluster --type=merge --patch '{"spec":{"defaultRoute":true}}'

# TODO: Is this really required?
# echo "${FMT_INF} Creating secret from entitlement key${FMT_END}"
# oc create secret docker-registry ibm-management-pull-secret \
#   --docker-username=cp \
#   --docker-password=${ENTITLED_REGISTRY_KEY} \
#   --docker-email=${ENTITLED_REGISTRY_USER_EMAIL} \
#   --docker-server=cp.icr.io \
#   --namespace=${DATA_NAMESPACE} \
#   --dry-run=client -o yaml | oc apply -f -

echo "${FMT_INF} Getting OpenShift Registry information${FMT_END}"
# TODO: Is this really required?
# oc login ${CLUSTER_ENDPOINT} --kubeconfig $KUBECONFIG

REGISTRY_FROM_CLUSTER="image-registry.openshift-image-registry.svc:5000/$DATA_NAMESPACE"

DEFAULT_ROUTE=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
[[ -z $DEFAULT_ROUTE ]] && {
  echo "${FMT_ERR} failed to get the OpenShift Registry default route${FMT_END}"
  exit 1
}
REGISTRY_LOCATION="${DEFAULT_ROUTE}/${DATA_NAMESPACE}"

# TODO:
#   According to the services to install new registries are added to the repo.yaml file.
#   Instructions at: https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/installation-files.html
# TODO: Setup Portworx if required

echo "${FMT_INF} Setup environment${FMT_END}"
# rm -rf ./cpd-cli-workspace
./cpd-cli adm \
  --repo repo.yaml \
  --assembly lite \
  --arch $ARCHITECTURE \
  --namespace $DATA_NAMESPACE

./cpd-cli adm \
  --repo repo.yaml \
  --accept-all-licenses \
  --assembly lite \
  --arch $ARCHITECTURE \
  --namespace $DATA_NAMESPACE \
  --apply

oc adm policy add-role-to-user cpd-admin-role $ADMIN \
  --role-namespace=$DATA_NAMESPACE \
  --namespace $DATA_NAMESPACE

echo "${FMT_INF} Installing Cloud Pak for Data${FMT_END}"
./cpd-cli install \
  --repo repo.yaml \
  --assembly lite \
  --arch $ARCHITECTURE \
  --namespace $DATA_NAMESPACE \
  --storageclass $STORAGE_CLASS_NAME \
  --cluster-pull-prefix $REGISTRY_FROM_CLUSTER \
  --transfer-image-to $REGISTRY_LOCATION \
  --target-registry-username $(oc whoami) \
  --target-registry-password $(oc whoami -t) \
  --insecure-skip-tls-verify \
  # --accept-all-license \
  # --dry-run

# TODO:
# If using Portworx, use:
# --storageclass portworx-shared-gp3 \
# --override cp-pwx-x86.YAML \

# TODO:
# If using OpenShift Container Storage, use:
# --storageclass ocs-storagecluster-cephfs \
# --override cp-ocs-x86.YAML \

[[ $? -ne 0 ]] && {
  echo "${FMT_ERR} failed to install Cloud Pak for Data${FMT_END}"
  exit 1
}

echo "${FMT_INF} Verifying Cloud Pack for Data installation${FMT_END}"
./cpd-cli status \
  --assembly lite \
  --arch $ARCHITECTURE \
  --namespace $DATA_NAMESPACE
