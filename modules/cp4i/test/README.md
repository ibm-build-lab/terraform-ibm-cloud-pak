Make sure `go` environment is set up:

```bash
brew install go
export $GOPATH=~/go
export PATH=/usr/local/go/bin:$PATH
```

Clone cp4i Terraform respository into `$GOPATH/src`.
```
git clone https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git $GOPATH/src
```

Change into the `test` subdirectory:

```bash
cd $GOPATH/srcgithub.com/ibm-hcbt/terraform-ibm-cloud-pak/modules/cp4i/test
```

export required Environment variables

```bash
export IC_API_KEY=<IBM Cloud Account API Key>
export CP_ENTITLEMENT=<Cloud Pak Entitlement Key>
export CP_ENTITLEMENT_EMAIL=<email of entitlement key owner>
```

Pull `go` packages:

```bash
go get -u "github.com/gruntwork-io/terratest/modules/random"
go get -u "github.com/gruntwork-io/terratest/modules/terraform"
```

Run the test:

```bash
 go test  -timeout 2h -v -run .
```