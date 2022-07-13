# Steps to run cloudpak_integration_test.go

This test case creates a ROKS classic cluster and installs Cloud Pak for Integration onto it.  You will need to manually delete the cluster when finished with your test.

## 1. Set up go environment

```bash
brew install go
export $GOPATH=~/go
export PATH=/usr/local/go/bin:$PATH
```

## 2. Clone the respository

Clone into `$GOPATH/src`.
```
cd $GOPATH/src/github.com/ibm-hcbt
git clone https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git
cd terraform-ibm-cloud-pak
```

## 3. Initialize go

```bash
go mod init
go mod tidy
```

## 3. Set variables

export required Environment variables

```bash
export IC_API_KEY=<IBM Cloud Account API Key>
export CP_ENTITLEMENT=<Cloud Pak Entitlement Key>
export CP_ENTITLEMENT_EMAIL=<email of entitlement key owner>
export RESOURCE_GROUP=<resource group to create cluster and install cp4i>
// run commands: `ibmcloud target -g <resource_group>`; `ibmcloud ks vlan ls --zone tor01` to get the vlans
export PRIVATE_VLAN=<private vlan for zone and resource group>
export PUBLIC_VLAN=<public vlan for zone and resource group>
```

## 4. Run the test:

```bash
cd $GOPATH/srcgithub.com/ibm-hcbt/terraform-ibm-cloud-pak/modules/cp4i/test
go test  -timeout 2h -v -run .
```