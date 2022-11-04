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
ibmcloud login --apikey $IC_API_KEY
ibmcloud ks cluster config -c $CLUSTER_ID

db2AdminUserName=db2inst1

# CP4BA Database Name information
db2UmsdbName=UMSDB
db2IcndbName=ICNDB
db2Devos1Name=DEVOS1
db2AeosName=AEOS
db2BawDocsName=BAWDOCS
db2BawTosName=BAWTOS
db2BawDosName=BAWDOS
db2BawDbName=BAWDB
db2AppdbName=APPDB
db2AedbName=AEDB
db2BasdbName=BASDB
db2GcddbName=GCDDB

echo
echo -e "\x1B[1mThis script CREATES all needed CP4BA databases (assumes Db2u is running in project ibm-db2). \n \x1B[0m"

echo
echo "Switching to project ibm-db2..."
oc project ibm-db2

echo
echo "Creating database ${db2UmsdbName}..."
oc cp createUMSDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createUMSDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createUMSDB.sh ${db2UmsdbName} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createUMSDB.sh"

echo
echo "Creating database ${db2IcndbName}..."
oc cp createICNDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createICNDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createICNDB.sh ${db2IcndbName} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createICNDB.sh"

echo
echo "Creating database ${db2Devos1Name}..."
oc cp createOSDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createOSDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createOSDB.sh ${db2Devos1Name} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createOSDB.sh"

echo "Creating database ${db2AeosName}..."
oc cp createOSDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createOSDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createOSDB.sh ${db2AeosName} ${db2AdminUserName}"

echo
echo "Creating database ${db2BawDocsName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createOSDB.sh ${db2BawDocsName} ${db2AdminUserName}"

echo
echo "Creating database ${db2BawDosName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createOSDB.sh ${db2BawDosName} ${db2AdminUserName}"

echo
echo "Creating database ${db2BawTosName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createOSDB.sh ${db2BawTosName} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createOSDB.sh"

echo
echo "Creating database ${db2BawDbName}..."
oc cp createBAWDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createBAWDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createBAWDB.sh ${db2BawDbName} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createBAWDB.sh"

echo
echo "Creating database ${db2AppdbName}..."
oc cp createAPPDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createAPPDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createAPPDB.sh ${db2AppdbName} ${db2AdminUserName}"

echo
echo "Creating database ${db2AedbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createAPPDB.sh ${db2AedbName} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createAPPDB.sh"

echo
echo "Creating database ${db2BasdbName}..."
oc cp createBASDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createBASDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createBASDB.sh ${db2BasdbName} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createBASDB.sh"

echo
echo "Creating database ${db2GcddbName}..."
oc cp createGCDDB.sh c-db2ucluster-db2u-0:/tmp/
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "chmod a+x /tmp/createGCDDB.sh"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "/tmp/createGCDDB.sh ${db2GcddbName} ${db2AdminUserName}"
oc exec c-db2ucluster-db2u-0 -it -- /bin/sh -c "rm /tmp/createGCDDB.sh"

echo
echo "Existing databases are:"
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 list database directory | grep \"Database name\""

echo
echo "Restarting Db2..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2stop"
sleep 5
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2start"
sleep 5

echo
echo "Activating databases..."
echo
echo "${db2UmsdbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2UmsdbName}"
sleep 5
echo
echo "${db2IcndbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2IcndbName}"

sleep 5
echo
echo "${db2Devos1Name}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2Devos1Name}"

sleep 5
echo
echo "${db2AeosName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2AeosName}"
sleep 5
echo
echo "${db2BawDocsName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2BawDocsName}"
sleep 5
echo
echo "${db2BawDosName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2BawDosName}"
sleep 5
echo
echo "${db2BawTosName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2BawTosName}"
sleep 5
echo
echo "${db2BawDbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2BawDbName}"
sleep 5
echo
echo "${db2AppdbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2AppdbName}"
sleep 5
echo
echo "${db2AedbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2AedbName}"
sleep 5
echo
echo "${db2BasdbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2BasdbName}"

sleep 5
echo
echo "${db2GcddbName}..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2 activate database ${db2GcddbName}"

echo
echo "Restarting Db2..."
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2stop"
sleep 5
oc exec c-db2ucluster-db2u-0 -it -- su - $db2AdminUserName -c "db2start"
sleep 5

echo
echo "Done. Exiting..."
echo
