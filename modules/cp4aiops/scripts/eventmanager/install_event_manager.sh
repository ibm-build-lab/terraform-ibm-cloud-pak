#!/bin/sh

# Set defaults
PERSISTENCE_FLAG=${INSTALL_PERSISTENCE:-true}

echo "=== installing event manager ==="

# $ADVANCED_FLAG
# $LDAP_FLAG
# $INTEGRATIONS_FLAG
$PERSISTENCE_FLAG
# $SERVICE_CONT_FLAG
# $TOPOLOGY_FLAG
# $ZEN_FLAG
# $BACKUP_RESTORE_FLAG

# Creates FQDN
FQDN=apps.`oc get ingresses.config/cluster -o jsonpath={.spec.domain}`

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
    serviceInstanceName: iaf-zen-cpdservice
  serviceContinuity:
    continuousAnalyticsCorrelation: false
    isBackupDeployment: false
  ldap:
    port: '3389'
    mode: standalone
    userFilter: 'uid=%s,ou=users'
    bindDN: 'cn=admin,dc=mycluster,dc=icp'
    sslPort: '3636'
    url: 'ldap://localhost:3389'
    suffix: 'dc=mycluster,dc=icp'
    groupFilter: 'cn=%s,ou=groups'
    baseDN: 'dc=mycluster,dc=icp'
    storageSize: 1Gi
    serverType: CUSTOM
    storageClass: ${LDAP_SC}
  backupRestore:
    enableAnalyticsBackups: false
  topology:
    storageClassElasticTopology: ${TOPOLOGY_SC}
    storageSizeElasticTopology: 75Gi
    storageSizeFileObserver: 5Gi
    storageClassFileObserver: ${TOPOLOGY_SC}
    iafCartridgeRequirementsName: ''
    appDisco:
      enabled: false
      scaleSSS: '1'
      tlsSecret: ''
      dbsecret: ''
      db2database: taddm
      dburl: ''
      certSecret: ''
      db2archuser: archuser
      secure: false
      scaleDS: '1'
      db2user: db2inst1
      dbport: '50000'
    observers:
      docker: false
      taddm: false
      servicenow: true
      ibmcloud: false
      alm: false
      contrail: false
      cienablueplanet: false
      kubernetes: true
      bigfixinventory: false
      junipercso: false
      dns: false
      itnm: false
      ansibleawx: false
      ciscoaci: false
      azure: false
      rancher: false
      newrelic: false
      vmvcenter: true
      rest: true
      appdynamics: false
      jenkins: false
      zabbix: false
      file: true
      googlecloud: false
      dynatrace: false
      aws: false
      openstack: false
      vmwarensx: false
    netDisco: false
  version: 1.6.3.2
  entitlementSecret: noi-registry-secret
  clusterDomain: >-
    ${FQDN}
  integrations:
    humio:
      repository: ''
      url: ''
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

    if [ `oc get NOI -n ${NAMESPACE} evtmanager -o json | jq -c -r '.status.phase'` == "OK" ]; then
        break
    fi

    echo "Sleeping ${SLEEP_TIME} seconds"
    sleep $SLEEP_TIME
    evtCount=$(( evtCount+1 ))
done

# Timeout check, fail out than let script "complete"
if [ $evtCount == $evtTimeout ]; then
    echo "EventManager timed out after ${evtTimeout} minutes. Please check the installation status of EventManager"
    exit 1
fi