# Steps to run cloudpak_integration_test.go

This test case creates a ROKS classic cluster and installs Cloud Pak for Integration onto it.

## 1. Set up go environment

```bash
brew install go
export $GOPATH=~/go
export PATH=/usr/local/go/bin:$PATH
```

## 2. Clone the respository

Clone into `$GOPATH/src`:

```bash
mkdir -p $GOPATH/src/github.com/ibm-build-labs
cd $GOPATH/src/github.com/ibm-build-labs
git clone https://github.com/ibm-build-labs/terraform-ibm-cloud-pak.git
cd terraform-ibm-cloud-pak
```

## 3. Initialize go in the clone tree

```bash
go mod init
go mod tidy
```

## 4. Set variables

export required Environment variables

```bash
export IC_API_KEY=<IBM Cloud Account API Key>
export CP_ENTITLEMENT=<Cloud Pak Entitlement Key>
export CP_ENTITLEMENT_EMAIL=<email of entitlement key owner>
export RESOURCE_GROUP=<resource group to create cluster and install cp4i>
// run commands: `ibmcloud target -g <resource_group>`; `ibmcloud ks vlan ls --zone tor01` to get the vlans
export PRIVATE_VLAN=<private vlan for zone and resource group>
export PUBLIC_VLAN=<public vlan for zone and resource group>
export ROKS_VERSION=<version of OpenShift to provision>
```

## 5. Run the test:

```bash
cd $GOPATH/src github.com/ibm-hcbt/terraform-ibm-cloud-pak/modules/cp4i/test
go test  -timeout 2h -v -run .
```

This will allow for the test to take up to 2 hours to run.  If it times out, restart command and change the `-timeout` value.
