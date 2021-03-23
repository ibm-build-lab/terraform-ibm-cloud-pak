# Configure Access to IBM Cloud

Terraform requires the IBM Cloud credentials to access IBM Cloud. The credentials can be set using environment variables or - optionally and recommended - in your own `credentials.sh` file.

## Create an IBM Cloud API Key

Follow these instructions to setup the **IBM Cloud API Key**, for more information read [Creating an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key).

In a terminal window, execute following commands replacing `<RESOURCE_GROUP_NAME>` with the resource group where you are planning to work and install everything:

```bash
ibmcloud login --sso
ibmcloud resource groups
ibmcloud target -g <RESOURCE_GROUP_NAME>
```

If you have an IBM Cloud API Key that is either not set or you don't have the JSON file when it was created, you must recreate the key. Delete the old one if it won't be in use anymore.

```bash
ibmcloud iam api-keys       # Identify your old API Key Name
ibmcloud iam api-key-delete NAME
```

Create new key

```bash
ibmcloud iam api-key-create TerraformKey -d "API Key for Terraform" --file ~/.ibm_api_key.json
export IC_API_KEY=$(grep '"apikey":' ~/.ibm_api_key.json | sed 's/.*: "\(.*\)".*/\1/')
```

## Create an IBM Cloud Classic Infrastructure API Key

Follow these instructions to get the **Username** and **API Key** to access **IBM Cloud Classic**, for more information read [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/account?topic=account-classic_keys).

1. At the IBM Cloud web console, go to **Manage** > **Access (IAM)** > **API keys**, and select **Classic infrastructure API keys** in the dropdown menu.
2. Click Create a classic infrastructure key. If you don't see this option, check to see if you already have a classic infrastructure API key that is created because you're only allowed to have one in the account per user.
3. Go to the actions menu (3 vertical dots) to select **Details**, then **Copy** the API Key.
4. Go to **Manage** > **Access (IAM)** > **Users**, then search and click on your user's name. Select **Details** at the right top corner to copy the **User ID** from the users info (it may be your email address).

## Setting the credentials

In the terminal window, export the following environment variables to let the IBM Provider to retrieve the credentials.

```bash
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"
export IC_API_KEY="< IBM Cloud API Key >"
```

So as to not have to define them for every new terminal, you can create the file `credentials.sh` containing the above credentials.

Execute the file like so:

```bash
source credentials.sh
```

Additionally, you can append the above `export` commands in your shell profile or config file (i.e. `~/.bashrc` or `~/.zshrc`) and they will be executed on every new terminal.

**IMPORTANT**: If you use a different filename than `credentials.sh` make sure to not commit the file to GitHub. The filename `credentials.sh` is in the `.gitignore` file so it is safe to use it..
