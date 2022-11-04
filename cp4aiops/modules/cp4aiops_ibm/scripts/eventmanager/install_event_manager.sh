#!/bin/sh

# Set defaults
ENABLE_PERSISTENCE=${ENABLE_PERSISTENCE:-true}

echo "=== installing event manager ==="

# Creates FQDN
FQDN=apps.`kubectl get ingresses.config/cluster -o jsonpath={.spec.domain}`

# Integrations
SET_HUMIO_REPO=${HUMIO_REPO:-''}
SET_HUMIO_URL=${HUMIO_URL:-''}

# Service Continuity (continuousAnalyticsCorrelation)
SET_CAC=${CAC:-false}
SET_BACKUP_DEPLOYMENT=${BACKUP_DEPLOYMENT:-false}

# Topologies
ENABLE_APP_DISC=${ENABLE_APP_DISC:-false}
SET_AP_CERT_SECRET=${AP_CERT_SECRET:-''}
SET_AP_DB_SECRET=${AP_DB_SECRET:-''}
SET_AP_DB_HOST_URL=${AP_DB_HOST_URL:-''}


# Backup Restore
ENABLE_BACKUP_RESTORE=${ENABLE_BACKUP_RESTORE:-false}


cat << EOF | kubectl apply -f -
apiVersion: noi.ibm.com/v1beta1
kind: NOI
metadata:
  namespace: ${NAMESPACE}
  name: evtmanager
spec:
  license:
    accept: ${ACCEPT_LICENSE}
  advanced:
    antiAffinity: false
    imagePullPolicy: IfNotPresent
    imagePullRepository: cp.icr.io/cp/noi
  zen:
    deploy: ${ENABLE_ZEN_DEPLOY}
    ignoreReady: ${ENABLE_ZEN_IGNORE_READY}
    instanceId: ${ZEN_INSTANCE_ID}
    serviceNamespace: ${ZEN_NAMESPACE}
    storage:
      storageClassName: ${ZEN_STORAGE}
    serviceInstanceName: ${ZEN_INSTANCE_NAME}
  serviceContinuity:
    continuousAnalyticsCorrelation: ${SET_CAC}
    isBackupDeployment: ${SET_BACKUP_DEPLOYMENT}
  ldap:
    port: "${LDAP_PORT}"
    mode: ${LDAP_MODE}
    userFilter: ${LDAP_USER_FILTER}
    bindDN: ${LDAP_BIND_DN}
    sslPort: "${LDAP_SSL_PORT}"
    url: ${LDAP_URL}
    suffix: ${LDAP_SUFFIX}
    groupFilter: ${LDAP_GROUP_FILTER}
    baseDN: ${LDAP_BASE_DN}
    storageSize: 1Gi
    serverType: ${LDAP_SERVER_TYPE}
    storageClass: ${LDAP_SC}
  backupRestore:
    enableAnalyticsBackups: ${ENABLE_BACKUP_RESTORE}
  topology:
    storageClassElasticTopology: ${TOPOLOGY_SC}
    storageSizeElasticTopology: 75Gi
    storageSizeFileObserver: 5Gi
    storageClassFileObserver: ${TOPOLOGY_SC}
    iafCartridgeRequirementsName: ''
    appDisco:
      enabled: ${ENABLE_APP_DISC}
      scaleSSS: '1'
      tlsSecret: ''
      dbsecret: ${SET_AP_DB_SECRET}
      db2database: taddm
      dburl: ${SET_AP_DB_HOST_URL}
      certSecret: ${SET_AP_CERT_SECRET}
      db2archuser: archuser
      secure: ${AP_SECURE_DB} 
      scaleDS: '1'
      db2user: db2inst1
      dbport: '50000'
    observers:
      docker: ${OBV_DOCKER}
      taddm: ${OBV_TADDM}
      servicenow: ${OBV_SERVICENOW}
      ibmcloud: ${OBV_IBMCLOUD}
      alm: ${OBV_ALM}
      contrail: ${OBV_CONTRAIL}
      cienablueplanet: ${OBV_CIENABLUEPLANET}
      kubernetes: ${OBV_KUBERNETES}
      bigfixinventory: ${OBV_BIGFIXINVENTORY}
      junipercso: ${OBV_JUNIPERCSO}
      dns: ${OBV_DNS}
      itnm: ${OBV_ITNM}
      ansibleawx: ${OBV_ANSIBLEAWX}
      ciscoaci: ${OBV_CISCOACI}
      azure: ${OBV_AZURE}
      rancher: ${OBV_RANCHER}
      newrelic: ${OBV_NEWRELIC}
      vmvcenter: ${OBV_VMVCENTER}
      rest: ${OBV_REST}
      appdynamics: ${OBV_APPDYNAMICS}
      jenkins: ${OBV_JENKINS}
      zabbix: ${OBV_ZABBIX}
      file: ${OBV_FILE}
      googlecloud: ${OBV_GOOGLECLOUD}
      dynatrace: ${OBV_DYNATRACE}
      aws: ${OBV_AWS}
      openstack: ${OBV_OPENSTACK}
      vmwarensx: ${OBV_VMWARENSX}
    netDisco: ${ENABLE_NETWORK_DISCOVERY}
  version: 1.6.3.2
  entitlementSecret: noi-registry-secret
  clusterDomain: >-
    ${FQDN}
  integrations:
    humio:
      repository: ${HUMIO_REPO}
      url: ${HUMIO_URL}
  persistence:
    storageSizeNCOBackup: 5Gi
    enabled: ${ENABLE_PERSISTENCE}
    storageSizeNCOPrimary: 5Gi
    storageClassNCOPrimary: ${PERSISTENT_SC}
    storageSizeImpactServer: 5Gi
    storageClassImpactServer: ${PERSISTENT_SC}
    storageClassKafka: ${PERSISTENT_SC}
    storageSizeKafka: 50Gi
    storageClassCassandraBackup: ${PERSISTENT_SC}
    storageSizeCassandraBackup: 50Gi
    storageClassZookeeper: ${PERSISTENT_SC}
    storageClassCouchdb: ${PERSISTENT_SC}
    storageSizeZookeeper: 5Gi
    storageSizeCouchdb: 20Gi
    storageClassCassandraData: ${PERSISTENT_SC}
    storageSizeCassandraData: 50Gi
    storageClassElastic: ${PERSISTENT_SC}
    storageClassImpactGUI: ${PERSISTENT_SC}
    storageSizeImpactGUI: 5Gi
    storageSizeElastic: 75Gi
    storageClassNCOBackup: ${PERSISTENT_SC}
  deploymentType: production
EOF

evtCount=0
evtTimeout=120 #2 hours
SLEEP_TIME="60"
while (( $evtCount < $evtTimeout )); do

  STATUS=`kubectl get NOI -n ${NAMESPACE} evtmanager -o json | jq -c -r '.status.phase'`
  if [ "$STATUS" == "OK" ]; then
    break
  fi

  echo "Current NOI Status: $STATUS"

  echo "Sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

# Timeout check, fail out than let script "complete"
if [ $evtCount == $evtTimeout ]; then
  echo "EventManager installation timed out after ${evtTimeout} minutes. Please check the installation status of EventManager"
  exit 1
fi