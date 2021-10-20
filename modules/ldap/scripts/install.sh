#!/bin/bash

echo "Installing IBM SDS.."


#Create folder structure
 
mkdir -p /repo/software/installables/V11.1/install
mkdir -p /repo/software/installables/V11.1/license
mkdir -p /repo/software/data/
mkdir -p /repo/software/installables/license/sdsV6.4/entitlement

#Get DB2 install
cd /repo/software
pwd

curl https://cosldap.s3.us-east.cloud-object-storage.appdomain.cloud/v11.1.4fp6_linuxx64_universal_fixpack.tar.gz --output /repo/software/v11.1.4fp6_linuxx64_universal_fixpack.tar.gz

echo "file downloaded from COS"

ls -l /repo/software

#Get DB2 license
cp /tmp/DB2_AWSE_Restricted_Activation_11.1.zip /repo/software/
cp /tmp/sds64-premium-feature-act-pkg.zip /repo/software/


#Extract files
cd /repo/software

tar xzvf /repo/software/v11.1.4fp6_linuxx64_universal_fixpack.tar.gz -C /repo/software/installables/V11.1/install

unzip /repo/software/DB2_AWSE_Restricted_Activation_11.1.zip -d /repo/software/installables/V11.1/license

unzip /repo/software/sds64-premium-feature-act-pkg.zip -d /repo/software/installables

#Copy response file
cp /tmp/db2server-V11.1.rsp /repo/software/data/

#Install DB2

cd /repo/software/installables/V11.1/install/universal/
./db2setup -r /repo/software/data/db2server-V11.1.rsp -l log.txt

#Apply License
/opt/ibm/db2/V11.1/adm/db2licm -a /repo/software/installables/V11.1/license/awse_o/db2/license/db2awse_o.lic


cd /repo/software
pwd

curl https://cosldap.s3.us-east.cloud-object-storage.appdomain.cloud/sds64-linux-x86-64.iso --output /repo/software/sds64-linux-x86-64.iso

echo "file sds64-linux-x86-64.iso downloaded from COS"

mkdir /mnt/iso

mount -t iso9660 -o loop /repo/software/sds64-linux-x86-64.iso /mnt/iso/

echo "Mount is complete"

groupadd idsldap
useradd -g idsldap -d /home/idsldap -m -s /bin/ksh idsldap

echo "Group and user added"

#passwd idsldap

usermod -a -G idsldap root

mkdir -p /opt/ibm/ldap/V6.4/install

touch /opt/ibm/ldap/V6.4/install/IBMLDAP_INSTALL_SKIPDB2REQ

cd /mnt/iso/ibm_gskit

rpm -Uhv gsk*linux.x86_64.rpm

echo "gsk*linux.x86_64.rpm complete"

## Install sds rpms
cd /mnt/iso/license
./idsLicense -q

echo "license complete "

## Enter 1 to accept the license agreement

cd /mnt/iso/images
rpm --force -ihv idsldap*rpm

echo "rpm --force -ihv idsldap*rpm license complete "

cd /repo/software/installables/sdsV6.4/entitlement
rpm --force -ihv idsldap-ent64-6.4.0-0.x86_64.rpm

echo "rpm --force -ihv idsldap-ent64-6.4.0-0.x86_64.rpm complete "

cd /mnt/iso/ibm_jdk
tar -xf 6.0.16.2-ISS-JAVA-LinuxX64-FP0002.tar -C /opt/ibm/ldap/V6.4/

## Setup db2 path
## Adjust based on your DB2 version
cat <<EOF >> /opt/ibm/ldap/V6.4/etc/ldapdb.properties
currentDB2InstallPath=/opt/ibm/db2/V11.1
currentDB2Version=11.1.4.6
EOF

## Create and configure instance
cd /opt/ibm/ldap/V6.4/sbin
./idsadduser -u dsinst1 -g grinst1 -w Passw0rd -n
## Enter 1 to continue

## Create instance
./idsicrt -I dsinst1 -p 389 -s 636 -e mysecretkey! -l /home/dsinst1 -G grinst1 -w Passw0rd -n
## Enter 1 to continue

## Configure a database for a directory server instance.
./idscfgdb -I dsinst1 -a dsinst1 -w Passw0rd -t dsinst1 -l /home/dsinst1 -n
## Enter 1 to continue

## Set the administration DN and administrative password for an instance
./idsdnpw -I dsinst1 -u $1 -p $2 -n

echo "idscfgsuf to run  "
## Add suffix
./idscfgsuf -I dsinst1 -s o=CP -n
## Confirm with 1
echo "idscfgsuf complete "

echo "idsldif2db to run  "
cd /opt/ibm/ldap/V6.4/sbin
./idsldif2db  -i /tmp/cp.ldif
echo "idsldif2db  complete "

echo "Test Start LDAP  "
cd /opt/ibm/ldap/V6.4/sbin
./ibmslapd -I dsinst1
echo "Start LDAP  complete"

